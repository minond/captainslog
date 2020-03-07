class Job::Runner
  prepend SimpleCommand

  def initialize(args, log)
    @args = args
    @log = log
  end

private

  attr_reader :args
  attr_reader :log
end
