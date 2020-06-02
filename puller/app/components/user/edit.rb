class User::Edit < Component
  props :user => User

  def render
    ViewContainer.render Section.render([header, form])
  end

  def header
    Header.render(:key => :settings)
  end

  def form
    User::Form.render(:user => user)
  end
end
