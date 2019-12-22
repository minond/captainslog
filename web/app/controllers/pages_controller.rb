class PagesController < ApplicationController
  def home
    @books = current_user&.books || []
  end
end
