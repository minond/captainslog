class Connection::QuickHistory < Component
  props :connection => Connection

  def render
    connection.recent_stats.map do |(id, status, _run_time)|
      Job::Status.render(:id => id, :status => status)
    end
  end
end
