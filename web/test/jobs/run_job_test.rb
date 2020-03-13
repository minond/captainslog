require "test_helper"

class RunJobTest < ActiveJob::TestCase
  test "it runs the job" do
    job = create(:job)
    assert_not job.done?
    RunJob.new.perform(job)
    assert job.done?
  end
end
