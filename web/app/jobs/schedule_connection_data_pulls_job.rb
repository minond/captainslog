class ScheduleConnectionDataPullsJob < ApplicationJob
  def perform
    connections.find_each(&:schedule_data_pull)
  end

private

  # @return [Array<Connection>]
  def connections
    Connection.is_active
              .last_update_attempted_over(6.hours.ago)
              .in_random_order
              .limit(10)
  end
end
