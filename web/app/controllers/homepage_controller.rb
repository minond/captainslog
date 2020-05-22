class HomepageController < ApplicationController
  include CallbackRedirect

  def home
    if current_user && callback.present?
      callback_redirect
    elsif current_user
      authenticated_landing_page
    else
      public_landing_page
    end
  end

private

  def authenticated_landing_page
    if current_user.homepage
      redirect_to current_user.homepage
    else
      redirect_to user_path
    end
  end

  def public_landing_page
    render "homepage/welcome"
  end
end
