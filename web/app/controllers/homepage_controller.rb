class HomepageController < ApplicationController
  def home
    current_user ? authenticated_landing_page : public_landing_page
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
