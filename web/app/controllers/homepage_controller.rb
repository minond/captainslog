class HomepageController < ApplicationController
  def home
    if current_user
      locals :books => books
    else
      render "homepage/welcome"
    end
  end
end
