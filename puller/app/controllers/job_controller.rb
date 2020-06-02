class JobController < ApplicationController
  # GET /jobs/1
  def show
    component :job => current_job
  end

private

  param_reader :id

  # @return [Job]
  def current_job
    @current_job ||= current_user.jobs.find(id)
  end
end
