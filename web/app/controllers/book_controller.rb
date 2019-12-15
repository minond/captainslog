class BookController < ApplicationController
  def show
    @books = current_user.books
    @book = current_user.books.find(params[:id])
  end
end
