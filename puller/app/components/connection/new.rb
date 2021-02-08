class Connection::New < ViewComponent
  def render
    ::ViewContainer.render [Connection::Options.render(:view_context => view_context)]
  end
end
