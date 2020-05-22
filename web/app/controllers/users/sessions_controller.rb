class Users::SessionsController < Devise::SessionsController
  include CallbackRedirect

  # POST /users/sign_in
  def create
    super do |user|
      if callback.present?
        callback_redirect(:user => user)
        return
      end
    end
  end
end
