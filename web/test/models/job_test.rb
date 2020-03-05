require "test_helper"

class JobTest < ActiveSupport::TestCase
  test "save happy path" do
    job = Job.new(:user => create(:user),
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
    job = Job.new(:user => create(:user),
                  :status => :running,
                  :args => "null",
                  :kind => :connection_data_pull_standard)

    assert_equal "running", job.run!
  end

private

  def user
    @user ||= create(:user)
  end
end
