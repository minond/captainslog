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

  # === URL
  #   POST /api/v1/books/:book_slug/entries
  #
  # === Request fields
  #   [String] book_slug - the book slug for the book the entry belongs to
  #   [Array<String>] texts - all entry texts
  #   [Array<Integer>] times - all entry timestamps
  #
  # === Sample request
  #   /api/v1/books/workouts/entries?texts[]=abc12&texts[]=abc13
  #
  def bulk_create
    texts.each_with_index do |text, i|
      current_book.add_entry(text, times(i))
    end
  end

private

  param_reader :book_slug
  param_reader :texts
  param_reader :text

  # @return [Book]
  def current_book
    current_user.books.by_slug(book_slug)
  end

  # @return [Time]
  def time
    Time.at(params[:time].to_i)
  end

  # @param [Integer] i
  # @return [Time]
  def times(i = nil)
    Time.at(params[:times][i].to_i)
  end
end
