class UsersController < UserSessionController
  # === URL
  #   GET /user
  #
  # === Sample request
  #   /user
  #
  def show
    locals :user => current_user
  end

  # === URL
  #   PATCH /user
  #
  # === Request fields
  #   [String] user[name] - the name
  #   [String] user[email] - the email address
  #   [String] user[timezone] - the timezone value
  #
  # === Sample request
  #   /user
  #
  def update
    ok = update_user
    notify(ok, :successful_user_update, :failure_in_user_update)
    ok ? redirect_to(user_path) : locals(:show, :user => current_user)
  end

private

  # Update the user and return true if there were not errors doing so.
  #
  # @return [Boolean]
  def update_user
    current_user.update(permitted_user_params)
    current_user.errors.empty?
  end

  # @return [ActionController::Parameters]
  def permitted_user_params
    params.require(:user)
          .permit(:name, :email, :timezone, :homepage)
  end
end
