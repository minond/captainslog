class PagesController < ApplicationController
  def home
    if current_user
      @books = current_user&.books || []
    else
      render "pages/welcome"
    end
  end
end
