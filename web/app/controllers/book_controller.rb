class BookController < ApplicationController
  # === URL
  #   GET /book/:id
  #
  # === Request fields
  #   [Integer] id - the book id for the book to load
  #
  # === Sample request
  #   /book/1
  #
  def show
    @books = current_user.books
    @book = current_book
  end

  # === URL
  #   POST /book/:id/entry
  #
  # === Request fields
  #   [Integer] id - the book id for the book to add the entry to
  #   [String] text - entry's original text
  #
  # === Sample request
  #   /book/1/entry?text=abc123
  #
  # === Sample response (HTML)
  #   Redirect to /book/1
  #
  def entry
    current_book.add_entry(params[:text])
    redirect_to(current_book)
  end

private

  # @return [Book]
  def current_book
    @current_book ||= current_user.books.find(current_book_id)
  end

  # @return [Number]
  def current_book_id
    params[:id] || params[:book_id]
  end
end
