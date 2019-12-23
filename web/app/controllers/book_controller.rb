class BookController < ApplicationController
  around_action :use_timezone, :if => :current_user

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
    locals :books => books,
           :book => book,
           :entries => entries,
           :requested_time => requested_time
  end

private

  # @return [Book]
  def book
    @book ||= books.find(params[:id])
  end

  # @return [Array<Book>]
  def books
    @books ||= current_user.books
  end

  # @return [Array<Entry>]
  def entries
    @entries ||=
      begin
        collection = book.find_collection(requested_time)
        collection.present? ? collection.entries : []
      end
  end
end
