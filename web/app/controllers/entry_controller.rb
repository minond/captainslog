class EntryController < ApplicationController
  around_action :user_timezone
  before_action :require_login

  # === URL
  #   DELETE /entry/:id
  #
  # === Request fields
  #   [Integer] id - the netry id for the entry to delete
  #
  # === Sample request
  #   /entry/1
  #
  # === Sample response (HTML)
  #   Redirect to previous page in session
  #
  def destroy
    current_entry.destroy
    redirect_to request.headers[:referer]
  end
end
