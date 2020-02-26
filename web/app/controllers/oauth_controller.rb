class OauthController < ApplicationController
  # === URL
  #   GET /oauth/fitbit
  #
  # === Request fields
  #   [String] code - oauth code
  #
  # === Sample request
  #   /oauth/fitbit?code=3j4k3lj4k3l2j32#_=_
  #
  def fitbit
    if setup_oauth_connection.success?
      redirect_to "/user#ok"
    else
      redirect_to "/user#error"
    end
  end

private

  # @return [String, nil]
  def code
    params[:code]
  end

  # @return [SetupOauthConnection]
  def setup_oauth_connection
    @setup_oauth_connection ||= SetupOauthConnection.call(current_user, :fitbit, code)
  end
end
