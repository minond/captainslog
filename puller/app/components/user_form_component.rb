class UserFormComponent < Component
  props :user => User

  def render
    FormComponent.render(:resource => user, :url => me_path) do |f|
      [
        FormFieldComponent.render(:form => f, :type => :email, :name => :email),
        FormSectionLabelComponent.render(:key => :update_password),
        FormFieldComponent.render(:form => f, :type => :password, :name => :current_password),
        FormFieldComponent.render(:form => f, :type => :password, :name => :password),
        FormFieldComponent.render(:form => f, :type => :password, :name => :password_confirmation),
        FormActionsComponent.render(:submit => true),
      ]
    end
  end
end
