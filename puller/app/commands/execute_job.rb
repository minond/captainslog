class ExecuteJob
  prepend SimpleCommand

  TICK_INTERVAL = 1.second
  PULL_BATCH_SIZE = 500

  # @param [Job] job
  def initialize(job)
    @job = job
    @sync_count = 0
    @errors = []
  end

  def call
    setup
    start_ticker
    sync_records
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
  delegate :oauth_authenticated?, :to => :client, :private => true

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

  # @return [Symbol]
  def status
    @errors.empty? ? :done : :errored
  end

  # @return [String]
  def message
    cc = @sync_count
    cr = "record".pluralize(cc)
    ec = @errors.count
    er = "error".pluralize(ec)
    "Synched #{cc} #{cr} with #{ec} #{er}."
  end

  # @return [StringIO]
  def logs
    @logs ||= StringIO.new
  end

  def sync_records
    connection.find_each_endpoint do |source, target|
      pull_and_push(source, target)
    end
  end

  # @param [Vertex] source
  # @param [Edge] target
  def pull_and_push(source, target)
    pull_args = pull_payload(source)

    Bag.open(PULL_BATCH_SIZE, push_proc(source, target)) do |bag|
      source.connection.client.send(pull_method, pull_args) do |record|
        logs.puts "pulling entry #{record.digest.strip}"
        @sync_count += 1
        bag << record
      end
    end
  end

  # @param [Vertex] source
  # @param [Edge] target
  def push_proc(source, target)
    resource = Service::Resource.from_urn(target.urn)
    proc do |records|
      logs.puts "pushing #{source.to_urn} to #{target.to_urn}"
      target.connection.client.push(records, resource)
    end
  end

  # @param [Vertex] source
  def pull_payload(source)
    { :resources => [URN.parse(source.urn).nss] }
  end

  # @return [Symbol]
  def pull_method
    case job.kind.to_sym
    when :backfill
      :pull_backfill
    when :pull
      :pull_standard
    end
  end

  def update_connection_credentials
    Credential.create_with_options(connection, credential_options) if oauth_authenticated?
  end
end
