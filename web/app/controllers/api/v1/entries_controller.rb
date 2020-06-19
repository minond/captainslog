class Api::V1::EntriesController < ApiController
  # === URL
  #   POST /api/v1/books/:book_id/entries
  #
  # === Request fields
  #   [String] book_id - the book's id
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

  param_reader :book_id
  param_reader :texts

  # @return [Book]
  def current_book
    current_user.books.find(book_id)
  end

  # @param [Integer] i
  # @return [Time]
  def times(i = nil)
    Time.at(params[:times][i].to_i)
  end
end
