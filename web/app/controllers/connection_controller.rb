class ConnectionController < ApplicationController
  CONNECTIONS = [
    {
      :logo => "fitbit-logo.png",
      :redirect => Rails.application.routes.url_helpers.fitbit_connection_index_path,
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
    cmd = setup_oauth_connection(:fitbit)
    if cmd.success?
      redirect_to cmd.result
    else
      redirect_to "/user#error"
    end
  end

  # === URL
  #   GET /connection/:id
  #
  # === Request fields
  #   [Integer] id - connection id
  #
  # === Sample request
  #   /connection/12
  #
  def show
    locals :connection => current_connection,
           :books => current_user.books
  end

  # === URL
  #   PATCH /connection/:id
  #
  # === Request fields
  #   [Integer] id - connection id
  #   [Integer] connection[book_id] - connection's book id
  #
  # === Sample request
  #   /connection/12
  #
  def update
    if update_connection
      flash.notice = t(:successful_connection_update)
      redirect_to user_path
    else
      flash.alert = t(:failure_in_connection_update)
      locals :show, :connection => current_connection,
                    :books => current_user.books
    end
  end

  # === URL
  #   DELETE /connection/:id
  #
  # === Request fields
  #   [Integer] id - the connection id for the connection to delete
  #
  # === Sample request
  #   /connection/1
  #
  # === Sample response (HTML)
  #   Redirect to previous page in session
  #
  def destroy
    current_connection.destroy
    redirect_to user_path
  end

  # === URL
  #   GET /connection/:id/schedule_data_pull
  #
  # === Request fields
  #   [Integer] id - the connection id for the connection to schedule a data pull for
  #
  # === Sample request
  #   /connection/1/schedule_data_pull
  #
  # === Sample response
  #   Redirect to job
  #
  def schedule_data_pull
    job = current_connection.schedule_data_pull_standard
    flash.notice = t(:scheduled_data_pull)
    redirect_to job
  end

private

  param_reader :id
  param_reader :code

  # @return [Connection]
  def current_connection
    @current_connection ||= current_user.connections.find(id)
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

  # Update the connection and return true if there were not errors doing so.
  #
  # @return [Boolean]
  def update_connection
    current_connection.update(permitted_connection_params)
    current_connection.errors.empty?
  end

  # @return [ActionController::Parameters]
  def permitted_connection_params
    params.require(:connection)
          .permit(:book_id)
  end
end
