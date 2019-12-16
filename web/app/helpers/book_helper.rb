module BookHelper
  # @param [Book] book
  # @param [Book, Nil] current_book
  # @return [String]
  def book_nav_class(book, current_book)
    book.id == current_book&.id ? "active" : nil
  end
end
