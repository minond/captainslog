class Connection::New < Component
  def render
    ViewContainer.render [Connection::Options.render]
  end
end
