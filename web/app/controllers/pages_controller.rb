class PagesController < ApplicationController
  def home
    if current_user
      locals :books => books
    else
      render "pages/welcome"
    end
  end
end
