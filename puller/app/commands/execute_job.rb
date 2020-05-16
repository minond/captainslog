class ExecuteJob
  prepend SimpleCommand

  # @param [Job] job
  def initialize(job)
    @job = job
    @create_count = 0
    @update_count = 0
    @errors = []
  end

  def call
    setup
    create_or_update_records
    update_connection_credentials
  rescue StandardError => e
    @errors << e
  ensure
    log_metrics
    teardown
  end

private

  attr_reader :job, :result

  delegate :connection, :to => :job, :private => true
  delegate :client, :to => :connection, :private => true
  delegate :credential_options, :to => :client, :private => true
  delegate :oauth?, :to => :client, :private => true

  def setup
    logs.puts "job setup"
    job.update!(:status => :running,
                :started_at => Time.now)
  end

  def log_metrics
    logs.puts "job completed"
    logs.puts "created: #{@create_count}"
    logs.puts "updated: #{@update_count}"
    logs.puts "errors: #{@errors.count}"
    @errors.each { |err| logs.puts "    - #{err.message}" }
  end

  def teardown
    logs.puts "job teardown"
    job.update!(:status => status,
                :stopped_at => Time.now,
                :message => message,
                :logs => logs.string)
  end

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

  def create_or_update_records
    pull_records do |record|
      logs.write "processing entry #{record.digest.strip} ... "
      logs.puts "created"
      @create_count += 1
    end
  end

  def pull_records(&block)
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
