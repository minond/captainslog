class ConnectionNewComponent < Component
  def render
    ContentComponent.render do
      AvailableConnectionsComponent.render
    end
  end
end
