module Service
  # @param [Symbol] service
  # @return [Class]
  def self.class_for_service(service)
    "Service::#{service.to_s.camelcase}".safe_constantize
  end

  # @param [Symbol] service
  # @param [String] auth_code
  # @return [Hash]
  def self.credentials_for_service(service, auth_code)
    client = class_for_service(service).new
    client.code = auth_code if client.oauth_authenticated?
    client.token = auth_code if client.token_authenticated?
    client.credential_options
  end

  # @param [Symbol] service
  # @param [Connection] connection, optional
  # @return [String]
  def self.auth_url_for_service(service, connection = nil)
    client = class_for_service(service).new
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

  # @param [Symbol] direction
  # @return [Class]
  def self.resource_class_for_direction(direction)
    "Service::Client::#{direction.to_s.camelcase}::Resource".safe_constantize
  end
end
