class Source::Client
  include OpenTracing::Instrumented
  include Source::Client::Configurable

  # @param [Symbol] source
  # @return [Class]
  def self.class_for_source(source)
    "Source::#{source.to_s.camelcase}".safe_constantize
  end

  # @param [Symbol] source
  # @param [String] auth_code
  # @return [Hash]
  def self.credentials_for_source(source, auth_code)
    client = class_for_source(source).new
    client.code = auth_code if client.oauth_authenticated?
    client.token = auth_code if client.token_authenticated?
    client.credential_options
  end

  # @param [Symbol] source
  # @param [Connection] connection, optional
  # @return [String]
  def self.auth_url_for_source(source, connection = nil)
    client = Source::Client.class_for_source(source).new
    client.auth_url(connection)
  end

  # @return [Symbol]
  def self.source
    name.demodulize.underscore.to_sym
  end

  # @param [Connection, nil] connection
  # @return [String]
  def self.encode_state(connection = nil)
    state = {}
    state[:connection_id] = connection.id if connection
    Base64.urlsafe_encode64(state.to_json)
  end

  # @param [String] encode_state
  # @param [Tuple<Integer>]
  def self.decode_state(encode_state)
    decoded_state = Base64.urlsafe_decode64(encode_state)
    state = JSON.parse(decoded_state).with_indifferent_access
    [state[:connection_id]]
  end

  # @param [Hash] options
  def initialize(options = {})
    client(options)
  end

  # Path to page where user can start the authentication process for this
  # source.
  #
  # @param [Connection, nil] connection
  # @return [String]
  def auth_url(_connection = nil)
    raise NotImplementedError, "#auth_url is not implemented"
  end

  # Path to page where user can start the authentication process for this
  # source.
  #
  # @return [String]
  def base_auth_url
    raise NotImplementedError, "#base_auth_url is not implemented"
  end

  # @return [Hash]
  def credential_options
    raise NotImplementedError, "#credential_options is not implemented"
  end

  # @return [Boolean]
  def oauth_authenticated?
    self.class < OauthAuthenticated
  end

  # @return [Boolean]
  def token_authenticated?
    self.class < TokenAuthenticated
  end

  # @return [Boolean]
  def input?
    self.class < Input
  end

  # @return [Boolean]
  def output?
    self.class < Output
  end
end
