class ApplicationJob < ActiveJob::Base
  retry_on ActiveRecord::Deadlocked
  discard_on ActiveJob::DeserializationError

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
