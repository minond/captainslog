class ProcessJobJob < ApplicationJob
  queue_as :default

  # @param [Integer] job_id
  def perform(job_id, command = ExecuteJob)
    command.call(Job.find(job_id))
  end
end
