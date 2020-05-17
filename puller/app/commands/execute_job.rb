class ExecuteJob
  prepend SimpleCommand

  TICK_INTERVAL = 1.second

  # @param [Job] job
  def initialize(job)
    @job = job
    @create_count = 0
    @update_count = 0
    @errors = []
  end

  def call
    setup
    start_ticker
    pull_records
    update_connection_credentials
  rescue StandardError => e
    @errors << e
  ensure
    log_errors
    stop_ticker
    teardown
  end

private

  attr_reader :job, :result

  delegate :connection, :to => :job, :private => true
  delegate :client, :to => :connection, :private => true
  delegate :credential_options, :to => :client, :private => true
  delegate :oauth?, :to => :client, :private => true

  def setup
    logs.puts "starting job, updating every #{TICK_INTERVAL}s"
    job.update!(:status => :running,
                :started_at => Time.now)
  end

  def start_ticker
    @ticker = Concurrent::TimerTask.execute(:execution_interval => TICK_INTERVAL) do
      job.update(:logs => logs.string)
    end
  end

  def stop_ticker
    @ticker.kill
  end

  def log_errors
    logs.puts "errors:" unless @errors.empty?
    @errors.each { |err| logs.puts "    - #{err.message}" }
  end

  # rubocop:disable Metrics/AbcSize
  def teardown
    job.assign_attributes(:status => status,
                          :message => message,
                          :stopped_at => Time.now)

    logs.puts "job completed in #{job.run_time}ms"
    job.update(:logs => logs.string)
    connection.update(:last_updated_at => Time.now)
  end
  # rubocop:enable Metrics/AbcSize

  def status
    @errors.empty? ? :done : :errored
  end

  def message
    cc = @create_count
    cr = "record".pluralize(cc)
    uc = @update_count
    ur = "record".pluralize(uc)
    ec = @errors.count
    er = "error".pluralize(ec)
    "Created #{cc} #{cr}, updated #{uc} #{ur}, with #{ec} #{er}."
  end

  def logs
    @logs ||= StringIO.new
  end

  def pull_records
    each_record do |record|
      logs.write "processing entry #{record.digest.strip} ... "
      logs.puts "created"
      @create_count += 1
    end
  end

  def each_record(&block)
    case job.kind.to_sym
    when :backfill
      client.data_pull_backfill(&block)
    when :pull
      client.data_pull_standard(&block)
    end
  end

  def update_connection_credentials
    Credential.create_with_options(connection, credential_options) if oauth?
  end
end
