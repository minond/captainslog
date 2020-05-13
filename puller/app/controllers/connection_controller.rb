class ConnectionController < ApplicationController
  KNOWN_SOURCES = %i[fitbit lastfm].freeze

  # GET /connection/new
  def new
    locals :connection => Connection.new,
           :known_sources => KNOWN_SOURCES
  end

  # POST /connection
  def create
    connection = create_connection

    if connection.save
      redirect_to :root, :notice => t(:connection_successfully_created)
    else
      locals :new, :connection => connection,
                   :known_sources => KNOWN_SOURCES
    end
  end

  # DELETE /connection/1
  def destroy
    current_connection.destroy
    redirect_to :root, :notice => t(:connection_successfully_deleted)
  end

  # GET /connection/:id/authenticate
  def authenticate
    redirect_to_auth_url(current_connection.source, current_connection)
  end

  # GET /connection/initiate/fitbit
  def fitbit_initiate
    redirect_to_auth_url :fitbit
  end

  # GET /connection/oauth/fitbit?code=...&state=...
  def fitbit_oauth
    handle_connection_auth_with_code :fitbit
  end

  # GET /connection/initiate/lastfm
  def lastfm_initiate
    redirect_to_auth_url :lastfm
  end

  # GET /connection/callback/lastfm?token=...&state=...
  def lastfm_callback
    handle_connection_auth_with_token :lastfm
  end

private

  param_reader :id
  param_reader :code
  param_reader :token
  param_reader :state

  # @return [Connection]
  def create_connection
    connection = Connection.new(connection_params)
    connection.user = current_user
    connection
  end

  # @return [Connection]
  def current_connection
    @current_connection ||= current_user.connections.find(id)
  end

  # @return [ActionController::Parameters]
  def connection_params
    params.require(:connection).permit(:source)
  end

  # @param [Symbol] source
  # @param [Connection, nil] connection
  def redirect_to_auth_url(source, connection = nil)
    redirect_to Source::Client.for_source(source).new.auth_url(connection)
  end

  # @param [Symbol] source
  # @return [SetupConnection, UpdateConnection]
  def handle_connection_auth_with_code(source)
    handle_connection_auth(source, code)
  end

  # @param [Symbol] source
  # @return [SetupConnection, UpdateConnection]
  def handle_connection_auth_with_token(source)
    handle_connection_auth(source, token)
  end

  # @param [Symbol] source
  # @param [String] service_auth_payload
  # @return [Array<SetupConnection, UpdateConnection, Boolean>]
  def command_for_connection_auth(source, service_auth_payload)
    connection_id, _rest = Source::Client.decode_state(state) if state
    if connection_id
      [update_connection_auth(connection_id, service_auth_payload), false]
    else
      [setup_connection_auth(source, service_auth_payload), true]
    end
  end

  # @param [Symbol] source
  # @param [String] service_auth_payload
  def handle_connection_auth(source, service_auth_payload)
    cmd, is_new = command_for_connection_auth(source, service_auth_payload)
    if cmd.success? && is_new
      redirect_to :root, :notice => t(:connection_successfully_created)
    elsif cmd.success?
      redirect_to :root, :notice => t(:connection_successfully_authenticated)
    else
      redirect_to :new, :notice => "bad"
    end
  end

  # @param [Integer] connection_id
  # @param [String] code
  # @return [UpdateConnection]
  def update_connection_auth(connection_id, code)
    connection = current_user.connections.find(connection_id)
    UpdateConnectionAuth.call(current_user, connection, code)
  end

  # @param [Symbol] source
  # @param [String] code
  # @return [SetupConnection]
  def setup_connection_auth(source, code)
    SetupConnectionAuth.call(current_user, source, code)
  end
end
