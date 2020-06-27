class Connection::New < ViewComponent
  def render
    ViewContainer.render [Connection::Options.render]
  end
end
