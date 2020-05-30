class JobChannel < ApplicationCable::Channel
  def subscribed
    if params[:job_id]
      stream_show_updates(:job, params[:job_id])
    else
      stream_index_updates(:job)
    end
  end
end
