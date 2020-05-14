class ExecuteJob
  prepend SimpleCommand

  # @param [Job] job
  def initialize(job)
    @job = job
  end

  def call
    setup
    execute
    teardown
  end

private

  attr_reader :job, :result

  def setup
    job.update!(:status => :running,
                :started_at => Time.now)
  end

  def execute
    @result = job.command.call(job.args, logs)
  end

  def teardown
    job.update!(:status => result.success? ? :done : :errored,
                :finished_at => Time.now,
                :logs => logs.string)
  end

  def logs
    @logs ||= StringIO.new
  end
end
