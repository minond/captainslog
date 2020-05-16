class HomeController < ApplicationController
  def home
    if current_user
      locals :user => current_user
    else
      redirect_to :new_user_session
    end
  end
end
