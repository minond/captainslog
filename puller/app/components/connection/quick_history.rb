class Connection::QuickHistory < ViewComponent
  props :connection => Connection

  def render
    connection.recent_metrics.map do |metric|
      Job::Status.render(:id => metric.job_id, :status => metric.job_status)
    end
  end
end
