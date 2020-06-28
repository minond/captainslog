require "test_helper"

class ApplicationJobTest < ActiveJob::TestCase
  # test "scheduler" do
  #   observer = TaskObserver.new
  #   task = ScheduleConnectionDataPullsJob.run_every(1.second)
  #   task.add_observer(observer)
  #   sleep 1.1
  #   task.kill
  #   assert observer.last_result.is_a?(ScheduleConnectionDataPullsJob)
  # end
end
