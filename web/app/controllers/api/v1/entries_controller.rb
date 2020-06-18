class Api::V1::EntriesController < ApiController
  # === URL
  #   POST /api/v1/books/:book_slug/entry
  #
  # === Request fields
  #   [String] book_slug - the book slug for the book the entry belongs to
  #   [String] text - entry's original text
  #   [Integer] time - entry timestamp
  #
  # === Sample request
  #   /api/v1/books/workouts/entry?text=abc123
  #
  def create
    entry = current_book.add_entry(text, time)
    json :id => entry.id,
         :errors => entry.errors.full_messages
  end

private

  param_reader :book_slug
  param_reader :text

  # @return [Book]
  def current_book
    current_user.books.by_slug(book_slug)
  end

  def time
    Time.at(params[:time].to_i)
  end
end
