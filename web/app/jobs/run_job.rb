class RunJob < ApplicationJob
  queue_as :default

  # @param [Job] job
  def perform(job)
    job.run!
  end
end
