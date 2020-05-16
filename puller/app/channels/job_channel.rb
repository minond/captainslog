class JobChannel < ApplicationCable::Channel
  def subscribed
    stream_from "jobs_for_user_#{current_user.id}"
  end
end
