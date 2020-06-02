class ConnectionController < ApplicationController
  # GET /connection/new
  def new
    component
  end

  # DELETE /connection/1
  def destroy
    current_connection.destroy
    redirect_to :root, :notice => t(:connection_successfully_deleted)
  end

  # GET /connection/:id/authenticate
  def authenticate
    redirect_to_auth_url(current_connection.service, current_connection)
  end

  # GET /connection/:id/schedule_pull
  def schedule_pull
    job = current_connection.schedule_pull
    if job&.errors&.empty?
      redirect_to :root, :notice => t(:pull_successfully_scheduled)
    else
      logger.error job&.errors
      redirect_to :root, :alert => t(:error_scheduling_pull)
    end
  end

  # GET /connection/initiate/captainslog
  def captainslog_initiate
    redirect_to_auth_url :captainslog
  end

  # GET /connection/callback/captainslog?token=...&state=...
  def captainslog_callback
    handle_connection_auth_with_token :captainslog
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
    params.require(:connection).permit(:service)
  end

  # @param [Symbol] service
  # @param [Connection, nil] connection
  def redirect_to_auth_url(service, connection = nil)
    redirect_to Service.auth_url_for_service(service, connection)
  end

  # @param [Symbol] service
  # @return [CreateConnection, UpdateConnection]
  def handle_connection_auth_with_code(service)
    handle_connection_auth(service, code)
  end

  # @param [Symbol] service
  # @return [CreateConnection, UpdateConnection]
  def handle_connection_auth_with_token(service)
    handle_connection_auth(service, token)
  end

  # @param [Symbol] service
  # @param [String] auth_code
  # @return [Array<CreateConnection, UpdateConnection, Boolean>]
  def command_for_connection_auth(service, auth_code)
    connection_id, _rest = Service.decode_state(state) if state
    if connection_id
      [update_connection_auth(connection_id, auth_code), false]
    else
      [create_connection_auth(service, auth_code), true]
    end
  end

  # @param [Symbol] service
  # @param [String] auth_code
  def handle_connection_auth(service, auth_code)
    cmd, is_new = command_for_connection_auth(service, auth_code)
    if cmd.success? && is_new
      redirect_to :root, :notice => t(:connection_successfully_created)
    elsif cmd.success?
      redirect_to :root, :notice => t(:connection_successfully_authenticated)
    else
      redirect_to :root, :alert => t(:error_creating_connection)
    end
  end

  # @param [Integer] connection_id
  # @param [String] auth_code
  # @return [UpdateConnection]
  def update_connection_auth(connection_id, auth_code)
    connection = current_user.connections.find(connection_id)
    UpdateConnectionAuth.call(current_user, connection, auth_code)
  end

  # @param [Symbol] service
  # @param [String] auth_code
  # @return [CreateConnection]
  def create_connection_auth(service, auth_code)
    CreateConnectionAuth.call(current_user, service, auth_code)
  end
end
