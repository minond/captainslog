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

private

  # @param [Symbol] data_source
  def redirect_to_auth_url(data_source)
    redirect_to Puller::Client.for_data_source(data_source).new.auth_url
  end
end
