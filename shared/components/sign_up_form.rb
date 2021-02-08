class SignUpForm < SignInForm
  props :user => User,
        :devise_mapping => [NilClass, Devise::Mapping]

  def fields(f)
    [
      Form::Field.render(:form => f, :name => :email, :type => :email, :autofocus => true),
      Form::Field.render(:form => f, :name => :password, :type => :password),
      Form::Field.render(:form => f, :name => :password_confirmation, :type => :password),
    ]
  end

  def actions(f)
    <<-HTML
      <div class="lh-copy mt4">
        #{f.submit t(:sign_up), :class => "f6 link bn pa0 input-reset pointer blue bg-white"}
        <span class="f6">#{t(:or)}</span>
        #{link_to t(:sign_in).downcase, new_user_session_path, :class => "link blue f6 link"}
      </div>
    HTML
  end
end
