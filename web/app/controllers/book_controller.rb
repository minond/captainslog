class BookController < ApplicationController
  around_action :user_timezone
  before_action :require_login

  # === URL
  #   GET /book/new
  #
  # === Sample request
  #   /book/new
  #
  def new
    locals :book => Book.new
  end

  # === URL
  #   POST /book
  #
  # === Request fields
  #   [String] slug - the slug for the book to load
  #   [String] book[name] - book's name
  #   [String] book[slug] - book's slug, auto generated when empty
  #   [Integer] book[grouping] - book's grouping type
  #
  # === Sample request
  #   /book
  #
  def create
    book = create_book
    ok = book.persisted?
    notify(ok, :successful_book_create, :failure_in_book_create)
    ok ? redirect_to(book.path) : locals(:new, :book => book)
  end

  # === URL
  #   GET /book/:slug
  #
  # === Request fields
  #   [String] slug - the slug for the book to load
  #
  # === Sample request
  #   /book/slugit
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
  #   [String] slug - the slug for the book to edit
  #
  # === Sample request
  #   /book/slugit
  #
  def edit
    locals :book => current_book
  end

  # === URL
  #   PATCH /book/:slug
  #
  # === Request fields
  #   [String] slug - the slug for the book to update
  #   [String] book[name] - book's name
  #   [String] book[slug] - book's slug
  #   [Integer] book[grouping] - book's grouping type
  #
  # === Sample request
  #   /book/slugit?name=Updated+Name&grouping=day
  #
  def update
    notify(update_book, :successful_book_update, :failure_in_book_update)
    redirect_to edit_book_path(current_book.slug)
  end

  # === URL
  #   DELETE /book/:slug
  #
  # === Request fields
  #   [String] slug - the slug for the book to delete
  #
  # === Sample request
  #   /book/slugit
  #
  def destroy
    current_book.destroy
    flash.notice = t(:successful_book_delete)
    redirect_to(user_path)
  end

private

  # @return [Array<Entry>]
  def entries
    @entries ||= current_book.find_entries(requested_time)
  end

  # @return [Book]
  def create_book
    Book.create(permitted_book_params.to_hash.merge(:user => current_user))
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
