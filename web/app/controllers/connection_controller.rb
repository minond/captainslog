class ConnectionController < ApplicationController
  CONNECTIONS = [
    {
      :logo => "fitbit-logo.png",
      :redirect => "/connection/fitbit",
      :description => I18n.t(:fitbit_connection_description),
    },
  ].freeze

  # === URL
  #   GET /connection/new
  #
  # === Sample request
  #   /connection/new
  #
  def new
    locals :connections => CONNECTIONS
  end

  # === URL
  #   GET /connection/fitbit
  #
  # === Sample request
  #   /connection/fitbit
  #
  def fitbit
    redirect_to_auth_url :fitbit
  end

  # === URL
  #   GET /connection/oauth/fitbit
  #
  # === Request fields
  #   [String] code - oauth code
  #
  # === Sample request
  #   /connection/oauth/fitbit?code=3j4k3lj4k3l2j32#_=_
  #
  def fitbit_oauth
    if setup_oauth_connection(:fitbit).success?
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

  # @param [Symbol] data_source
  def redirect_to_auth_url(data_source)
    redirect_to DataSource::Client.for_data_source(data_source).new.auth_url
  end

  # @param [Symbol] data_source
  # @return [SetupOauthConnection]
  def setup_oauth_connection(data_source)
    @setup_oauth_connection ||= SetupOauthConnection.call(current_user, data_source, code)
  end
end
