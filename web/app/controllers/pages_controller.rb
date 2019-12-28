class PagesController < ApplicationController
  def home
    if current_user
      locals :books => current_user.books
    else
      render "pages/welcome"
    end
  end
end
