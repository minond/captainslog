class JobController < ApplicationController
  # === URL
  #   GET /job/:id
  #
  # === Request fields
  #   [Integer] id - the id of the job to show
  #
  # === Sample request
  #   /job/4
  #
  def show
    locals :job => current_job
  end

private

  param_reader :id

  # @return [Job]
  def current_job
    current_user.jobs.find(id)
  end
end
