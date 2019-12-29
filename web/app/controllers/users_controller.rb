class UsersController < ApplicationController
  # === URL
  #   GET /users
  #
  # === Sample request
  #   /user
  #
  def show
    locals :user => current_user
  end

  # === URL
  #   GET /user
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
    notify(update_user, :successful_user_update, :failure_in_user_update)
    locals "user/show", :user => current_user
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
          .permit(:name, :email, :timezone)
  end
end
