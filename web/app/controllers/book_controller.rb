class BookController < ApplicationController
  around_action :user_timezone
  before_action :require_login

  # === URL
  #   GET /book/:id
  #
  # === Request fields
  #   [Integer] id - the id for the book to load
  #
  # === Sample request
  #   /book/1
  #
  def show
    locals :book => current_book,
           :entries => entries,
           :requested_time => requested_time
  end

private

  # @return [Array<Entry>]
  def entries
    @entries ||=
      begin
        collection = current_book.find_collection(requested_time)
        collection.present? ? collection.entries.order("created_at desc") : []
      end
  end
end
