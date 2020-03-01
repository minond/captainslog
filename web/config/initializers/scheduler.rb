return if defined?(Rails::Console) || Rails.env.test? || ARGV.first != "jobs:work"

puts "Initializing scheduler"

# Monkeypatch ApplicationJob to a nicer scheduler syntax.
class ApplicationJob
  # @param [ActiveSupport::Duration] interval
  # @return [Concurrent::TimerTask]
  def self.run_every(interval)
    puts "Scheduling #{self} to run every #{interval.inspect}"

    Concurrent::TimerTask.new(:execution_interval => interval) do
      puts "Queueing #{self} for execution"
      perform_later
    end.execute
  end
end

ScheduleConnectionDataPullsJob.run_every 2.hours
