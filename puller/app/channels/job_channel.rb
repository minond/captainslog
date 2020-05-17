class JobChannel < ApplicationCable::Channel
  def subscribed
    stream_from "jobs_for_user_#{current_user.id}", :coder => ActiveSupport::JSON do |payload|
      job = Job.find(payload["job_id"])
      connection = Connection.find(payload["connection_id"])

      transmit :job => { :id => job.id },
               :connection => { :id => connection.id },
               :job_row_html => render("job/row", :job => job),
               :connection_row_html => render("connection/row", :connection => connection)
    end
  end
end
