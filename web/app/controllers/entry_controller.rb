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
end
