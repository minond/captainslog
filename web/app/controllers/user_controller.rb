class UserController < ApplicationController
  def edit
    locals :user => current_user,
           :books => books
  end

  def update
    if update_user
      flash.notice = t(:successful_user_update)
    else
      flash.alert = t(:failure_in_user_update)
    end

    redirect_to edit_user_path(current_user)
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
          .permit(:email, :timezone)
  end
end
