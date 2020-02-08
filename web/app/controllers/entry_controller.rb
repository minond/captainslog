class EntryController < ApplicationController
  around_action :user_timezone
  before_action :require_login

  # === URL
  #   POST /book/:slug/entry
  #
  # === Request fields
  #   [String] slug - the book slug for the book the entry belongs to
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
  #   GET /book/:slug/entry/:id
  #
  # === Request fields
  #   [String] slug - the book slug for the book the entry belongs to
  #   [Integer] id - the entry id for the entry to show
  #
  # === Sample request
  #   /entry/1
  #
  def show
    respond_to do |format|
      format.html { locals :entry => current_entry }
      format.js { render :partial => "entry/update", :locals => { :entry => current_entry } }
    end
  end

  # === URL
  #   GET /book/:slug/entry/:id
  #
  # === Request fields
  #   [String] slug - the book slug for the book the entry belongs to
  #   [Integer] id - the entry id for the entry to show
  #   [Integer] entry[original_text] - entry text
  #
  # === Sample request
  #   /entry/1
  #
  def update
    notify(update_entry, :successful_entry_update, :failure_in_entry_update)
    redirect_to current_entry.collection_path
  end

  # === URL
  #   DELETE /book/:slug/entry/:id
  #
  # === Request fields
  #   [String] slug - the book slug for the book the entry belongs to
  #   [Integer] id - the entry id for the entry to delete
  #
  # === Sample request
  #   /entry/1
  #
  # === Sample response (HTML)
  #   Redirect to previous page in session
  #
  def destroy
    home = current_entry.collection_path
    current_entry.destroy
    redirect_to home
  end

private

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
