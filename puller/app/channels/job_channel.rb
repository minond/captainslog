class JobChannel < ApplicationCable::Channel
  def subscribed
    stream_from "jobs_for_user_#{current_user.id}", :coder => ActiveSupport::JSON do |payload|
      job = Job.new(payload["job"])
      connection = Connection.new(payload["connection"])


      transmit :job => payload["job"],
               :job_row_html => render("job/row", :job => job),
               :connection_row_html => render("connection/row", :connection => connection)
    end
  end
end
