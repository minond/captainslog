class RunJob < ApplicationJob
  # @param [Job] job
  def perform(job)
    job.run!
  end
end
