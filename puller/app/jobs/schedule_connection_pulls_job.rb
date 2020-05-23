class ScheduleConnectionPullsJob < ApplicationJob
  queue_as :default

  def perform
    Connection.in_need_of_pull.find_each(&:schedule_pull)
  end
end
