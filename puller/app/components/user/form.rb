class User::Form < Component
  props :user => User

  def render
    Form.render(:resource => user, :url => me_path) do |f|
      [
        Form::Field.render(:form => f, :type => :email, :name => :email),
        Form::SectionLabel.render(:key => :update_password),
        Form::Field.render(:form => f, :type => :password, :name => :current_password),
        Form::Field.render(:form => f, :type => :password, :name => :password),
        Form::Field.render(:form => f, :type => :password, :name => :password_confirmation),
        Form::Actions.render(:submit => true),
      ]
    end
  end
end
