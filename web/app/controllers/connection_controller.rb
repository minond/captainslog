class ConnectionController < UserSessionController
  # @param [Symbol] name
  # @return [Hash]
  def self.build_connection_item(name, logo_extension: "png")
    {
      :logo => "#{name}-logo.#{logo_extension}",
      :redirect => Rails.application.routes.url_helpers.send(:"#{name}_connection_index_path"),
      :description => I18n.t(:"#{name}_connection_description"),
    }
  end

  CONNECTIONS = [
    build_connection_item(:fitbit),
    build_connection_item(:lastfm, :logo_extension => "svg"),
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
  #   [String] state - encoded state string. see `DataSource::Client.encode_state`
  #
  # === Sample request
  #   /connection/oauth/fitbit?code=3j4k3lj4k3l2j32#_=_
  #
  def fitbit_oauth
    cmd = handle_connection(:fitbit)
    if cmd.success?
      redirect_to cmd.result
    else
      redirect_to "/user#error"
    end
  end

  # === URL
  #   GET /connection/lastfm
  #
  # === Sample request
  #   /connection/lastfm
  #
  def lastfm
    redirect_to_auth_url :lastfm
  end

  # === URL
  #   GET /connection/callback/lastfm
  #
  # === Request fields
  #   [String] token - auth code
  #   [String] state - encoded state string. see `DataSource::Client.encode_state`
  #
  # === Sample request
  #   /connection/callback/lastfm?code=3j4k3lj4k3l2j32#_=_
  #
  def lastfm_callback
    cmd = handle_connection(:lastfm, token)
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
    job = current_connection.schedule_data_pull_manual
    flash.notice = t(:scheduled_data_pull)
    redirect_to job
  end

  # === URL
  #   GET /connection/:id/authenticate
  #
  # === Request fields
  #   [Integer] id - the connection id for the connection to authenticate
  #
  # === Sample request
  #   /connection/1/authenticate
  #
  # === Sample response
  #   Redirect to job
  #
  def authenticate
    redirect_to_auth_url(current_connection.data_source, current_connection)
  end

private

  param_reader :id
  param_reader :code
  param_reader :token
  param_reader :state

  # @return [Connection]
  def current_connection
    @current_connection ||= current_user.connections.find(id)
  end

  # @param [Symbol] data_source
  # @param [Connection, nil] connection
  def redirect_to_auth_url(data_source, connection = nil)
    redirect_to DataSource::Client.for_data_source(data_source).new.auth_url(connection)
  end

  # @param [Symbol] data_source
  # @param [String] code_str, defaults to `#code`
  # @return [SetupConnection, UpdateConnection]
  def handle_connection(data_source, code_str = code)
    connection_id, _rest = DataSource::Client.decode_state(state) if state
    if connection_id
      update_connection_auth(connection_id, code_str)
    else
      setup_connection_auth(data_source, code_str)
    end
  end

  # @param [Integer] connection_id
  # @param [String] code
  # @return [UpdateConnection]
  def call_update_connection(connection_id, code)
    connection = current_user.connections.find(connection_id)
    UpdateConnectionAuth.call(current_user, connection, code)
  end

  # @param [Symbol] data_source
  # @param [String] code
  # @return [SetupConnection]
  def call_setup_connection(data_source, code)
    SetupConnectionAuth.call(current_user, data_source, code)
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
