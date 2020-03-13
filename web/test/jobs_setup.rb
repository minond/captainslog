class TestArgs < Job::Args
  define_attributes :initialize => true, :attributes => true do
    attribute :int, Integer
    attribute :str, String
  end
end

class TestLogRunner < Job::Runner
  prepend SimpleCommand
  def call
    log.puts "running job"
  end
end

class TestErrorRunner < Job::Runner
  prepend SimpleCommand
  def call
    errors.add :err1, "error1"
    errors.add :err2, "error2"
  end
end

class TestExceptionRunner < Job::Runner
  prepend SimpleCommand
  def call
    raise StandardError, "err"
  end
end

Job.register :test_log, TestArgs, TestLogRunner
Job.register :test_error, TestArgs, TestErrorRunner
Job.register :test_exception, TestArgs, TestExceptionRunner
