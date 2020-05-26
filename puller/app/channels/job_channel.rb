class JobChannel < ApplicationCable::Channel
  def subscribed
    params[:job_id] ? stream_job_updates(params[:job_id]) : stream_all_job_updates
  end

  # Used to stream updates to a job page.
  def stream_job_updates(requested_job_id)
    stream_from "jobs_for_user_#{current_user.id}", :coder => ActiveSupport::JSON do |payload|
      transmit render_job_update(payload) if payload["job_id"] == requested_job_id
    end
  end

  # Used to stream updates to the home page.
  def stream_all_job_updates
    stream_from "jobs_for_user_#{current_user.id}", :coder => ActiveSupport::JSON do |payload|
      transmit render_home_update(payload)
    end
  end

  # Takes the payload broadcasted after a job update. This payload includes a
  # job id (job_id) and a connection id (connection_id). Using this
  # information, this method loads those records and renders HTML that is ready
  # to be injected in the home page.
  #
  # @param [Hash] payload
  # @return [Hash]
  def render_home_update(payload)
    job = Job.find(payload["job_id"])
    connection = Connection.find(payload["connection_id"])

    {
      :job => { :id => job.id },
      :connection => { :id => connection.id },
      :job_row_html => JobRowComponent.render(:job => job),
      :connection_row_html => ConnectionRowComponent.render(:connection => connection)
    }
  end

  # Takes the payload broadcasted after a job update. This payload includes a
  # job id (job_id) and a connection id (connection_id). Using this
  # information, this method loads the job and returns a hash with the
  # view-friendly values that will be injected in the job show page.
  #
  # @param [Hash] payload
  # @return [Hash]
  def render_job_update(payload)
    job = Job.find(payload["job_id"])

    { :job => job.presenter.details }
  end
end
