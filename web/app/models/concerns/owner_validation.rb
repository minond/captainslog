# Helpers for checking that the current resource and it associations are all
# owned by the same user.
module OwnerValidation
private

  # Ensures the book (`book_id`) is found in the user's (`user_id`) list of
  # books.
  def book_is_owned_by_user
    user.books.find(book_id)
  rescue ActiveRecord::RecordNotFound
    errors.add(:book, "not found")
  end
end
