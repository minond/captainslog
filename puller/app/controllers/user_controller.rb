class UserController < ApplicationController
  # GET /me
  def edit
    component User::Edit, :user => current_user
  end

  # PATCH /me
  def update
    if current_user.update(user_params)
      bypass_sign_in(current_user)
      redirect_to :me
    else
      component User::Edit, :user => current_user
    end
  end

private

  def user_params
    params.require(:user)
          .permit(:email, :password, :new_password, :new_password_confirmation)
  end
end
