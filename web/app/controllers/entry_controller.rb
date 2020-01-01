class EntryController < ApplicationController
  before_action :require_login

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
    current_entry.update(entry_update_attributes)
    current_entry.errors.empty?
  end

  # @return [ActionController::Parameters]
  def permitted_entry_params
    params.permit(:original_text)
  end

  # @return [Hash]
  def entry_update_attributes
    permitted_entry_params.to_hash.merge(:processed_text => nil)
  end
end
