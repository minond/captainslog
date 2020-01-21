class EntriesController < ApplicationController
  around_action :user_timezone
  before_action :require_login

  # === URL
  #   POST /book/:book_id/entry
  #
  # === Request fields
  #   [Integer] book_id - the book id for the book to add the entry to
  #   [String] text - entry's original text
  #
  # === Sample request
  #   /book/1/entry?text=abc123
  #
  # === Sample response (HTML)
  #   Redirect to /book/1
  #
  def create
    current_book.add_entry(params[:text], requested_time)
    redirect_to book_at_path(current_book.slug, requested_time.to_i)
  end

  # === URL
  #   GET /entry/:id
  #
  # === Request fields
  #   [Integer] id - the entry id for the entry to show
  #
  # === Sample request
  #   /entry/1
  #
  def show
    locals :entry => current_entry
  end

  # === URL
  #   GET /entry/:id
  #
  # === Request fields
  #   [Integer] id - the entry id for the entry to show
  #
  # === Sample request
  #   /entry/1
  #
  def update
    notify(update_entry, :successful_entry_update, :failure_in_entry_update)
    redirect_to :back
  end

  # === URL
  #   DELETE /entry/:id
  #
  # === Request fields
  #   [Integer] id - the entry id for the entry to delete
  #
  # === Sample request
  #   /entry/1
  #
  # === Sample response (HTML)
  #   Redirect to previous page in session
  #
  def destroy
    current_entry.destroy
    redirect_to(request.headers[:referer] || root_path)
  end

private

  # Generate the url to be used when calling `redirect_to :back`
  #
  # @return [String]
  def back_url
    go_back_path(3) || current_entry.collection_path
  end

  # Update the entry and return true if there were not errors doing so.
  #
  # @return [Boolean]
  def update_entry
    current_entry.update(permitted_entry_params)
    current_entry.errors.empty?
  end

  # @return [ActionController::Parameters]
  def permitted_entry_params
    params.permit(:original_text)
  end
end
