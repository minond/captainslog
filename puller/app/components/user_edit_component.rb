class UserEditComponent < Component
  props :user => User

  def render
    ContentComponent.render SectionComponent.render([header, form])
  end

  def header
    HeaderComponent.render(:key => :settings)
  end

  def form
    UserFormComponent.render(:user => user)
  end
end
