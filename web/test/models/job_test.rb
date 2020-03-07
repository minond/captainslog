require "test_helper"

class JobTest < ActiveSupport::TestCase
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
      errors.add :xs, "ys"
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

  test "save happy path" do
    job = Job.new(:user => user,
                  :status => :initiated,
                  :args => "null",
                  :kind => :connection_data_pull_standard)
    assert job.save
  end

  test "schedule! happy path" do
    args = Job::ConnectionDataPullStandardArgs.new(:connection_id => 1)
    assert Job.schedule!(user, :connection_data_pull_standard, args)
  end

  test "schedule! with invalid kind" do
    args = Job::ConnectionDataPullStandardArgs.new(:connection_id => 1)
    assert_raises(ArgumentError) { Job.schedule!(user, :connection_data_pull_standard_invalid, args) }
  end

  test "schedule! with invalid arguments" do
    args = Job::ConnectionDataPullBackfillArgs.new(:connection_id => 1)
    assert_raises(ArgumentError) { Job.schedule!(user, :connection_data_pull_standard, args) }
  end

  test "decoded_args" do
    args = Job::ConnectionDataPullStandardArgs.new(:connection_id => 1)
    job = Job.schedule!(user, :connection_data_pull_standard, args)
    assert_equal job.decoded_args.connection_id, args.connection_id
  end

  test "run! immediatelly return on non-runnable statuses" do
    job = Job.new(:user => user,
                  :status => :running,
                  :args => "null",
                  :kind => :connection_data_pull_standard)

    assert_equal "running", job.run!
  end

  test "an exception is raised when an invalid job kind is used" do
    assert_raises(Job::InvalidKind) { Job.schedule!(user, :invalid, TestArgs.new) }
  end

  test "an exception is raised when an invalid argument class is used" do
    assert_raises(Job::InvalidArguments) { Job.schedule!(user, :test_log, User.new) }
  end

  test "logs are accessible after the job has ran" do
    job = Job.schedule!(user, :test_log, TestArgs.new)
    job.run!
    assert_equal job.logs, "running job\n"
  end

private

  def user
    @user ||= create(:user)
  end
end
