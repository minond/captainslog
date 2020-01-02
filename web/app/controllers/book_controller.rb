class BookController < ApplicationController
  around_action :user_timezone
  before_action :require_login

  # === URL
  #   GET /book/new
  #
  # === Sample request
  #   /book/new
  #
  def new; end

  # === URL
  #   POST /book
  #
  # === Sample request
  #   /book
  #
  def create
    book = Book.create(permitted_book_params.to_hash.merge(:user => current_user))
    redirect_to book_path(book.slug)
  end

  # === URL
  #   GET /book/:slug
  #
  # === Request fields
  #   [Integer] slug - the slug for the book to load
  #
  # === Sample request
  #   /book/1
  #
  def show
    locals :book => current_book,
           :entries => entries,
           :requested_time => requested_time
  end

  # === URL
  #   GET /book/:slug/edit
  #
  # === Request fields
  #   [Integer] slug - the slug for the book to edit
  #
  # === Sample request
  #   /book/1
  #
  def edit
    locals :book => current_book
  end

  # === URL
  #   PATCH /book/:slug
  #
  # === Request fields
  #   [Integer] slug - the slug for the book to update
  #
  # === Sample request
  #   /book/1?name=Updated+Name&grouping=day
  #
  def update
    notify(update_book, :successful_book_update, :failure_in_book_update)
    redirect_to edit_book_path(current_book.slug)
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

  # Update the book and return true if there were not errors doing so.
  #
  # @return [Boolean]
  def update_book
    current_book.update(permitted_book_params)
    current_book.errors.empty?
  end

  # @return [ActionController::Parameters]
  def permitted_book_params
    params.require(:book)
          .permit(:name, :slug, :grouping)
  end
end
