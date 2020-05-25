class ConnectionJobHistoryComponent < Component
  props :connection => Connection

  def render
    connection.recent_stats.map do |(id, status, _run_time)|
      JobStatusComponent.render(:id => id, :status => status)
    end
  end
end
