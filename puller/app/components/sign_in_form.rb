class SignInForm < ViewComponent
  props :user => User,
        :devise_mapping => [NilClass, Devise::Mapping]

  def render
    <<-HTML
      <div class="center mw7 mt4 ph4">
        #{logo}
        #{description}
        #{form}
      </div>
    HTML
  end

  def logo
    AppLogo.render
  end

  def description
    <<-HTML
      <p class="lh-copy mb4">#{t(:intro_message)}</p>
    HTML
  end

  def form
    Form.render(:resource => user, :url => new_user_session_path) do |f|
      [
        fields(f),
        remember_me(f),
        actions(f)
      ]
    end
  end

  def form_url
    new_user_session_path
  end

  def fields(f)
    [
      Form::Field.render(:form => f, :name => :email, :type => :email, :autofocus => true),
      Form::Field.render(:form => f, :name => :password, :type => :password),
    ]
  end

  def remember_me(f)
    return "" unless devise_mapping&.rememberable?

    <<-HTML
      <div class="mt2">
        <label class="f6 lh-copy">
          #{f.check_box :remember_me}
          #{t(:remember_me)}
        </label>
      </div>
    HTML
  end

  def actions(f)
    <<-HTML
      <div class="lh-copy mt4">
        #{f.submit t(:sign_in), :class => "f6 link bn pa0 input-reset pointer blue bg-white"}
        <span class="f6">#{t(:or)}</span>
        #{link_to t(:sign_up).downcase, new_user_registration_path, :class => "link blue f6 link"}
      </div>
    HTML
  end
end
