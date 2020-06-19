class Api::V1::EntriesController < ApiController
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
  def create
    texts.each_with_index do |text, i|
      current_book.add_entry(text, times(i))
    end
  end

private

  param_reader :book_slug
  param_reader :texts

  # @return [Book]
  def current_book
    current_user.books.by_slug(book_slug)
  end

  # @param [Integer] i
  # @return [Time]
  def times(i = nil)
    Time.at(params[:times][i].to_i)
  end
end
