class UserEditComponent < Component
  props :user => User

  def render
    ContentComponent.render do
      SectionComponent.render do
        [
          HeaderComponent.render(:key => :settings),
          UserFormComponent.render(:user => user),
        ]
      end
    end
  end
end
