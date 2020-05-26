class ConnectionNewComponent < Component
  def render
    ContentComponent.render [AvailableConnectionsComponent.render]
  end
end
