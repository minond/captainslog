module Service
  # @param [Symbol] source
  # @return [Class]
  def self.class_for_source(source)
    "Service::#{source.to_s.camelcase}".safe_constantize
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
    client = class_for_source(source).new
    client.auth_url(connection)
  end

  # @param [Connection, nil] connection
  # @return [String]
  def self.encode_state(connection = nil)
    state = {}
    state[:connection_id] = connection.id if connection
    Base64.urlsafe_encode64(state.to_json)
  end

  # @param [String] encoded_state
  # @param [Tuple<Integer>]
  def self.decode_state(encoded_state)
    decoded_state = Base64.urlsafe_decode64(encoded_state)
    state = JSON.parse(decoded_state).with_indifferent_access
    [state[:connection_id]]
  end
end
