class SetupOauthConnection
  prepend SimpleCommand

  # @param [User] user
  # @param [Symbol] data_source
  # @param [String] code
  def initialize(user, data_source, code)
    @user = user
    @data_source = data_source
    @code = code
  end

  # @return [Connection, nil]
  def call
    validate
    return unless errors.empty?

    connection_with_credentials
  end

private

  attr_reader :user, :data_source, :code

  def validate
    errors.add :missing_user, "a user is required" unless user.present?
    errors.add :missing_code, "an oath code is required" unless code.present?
  end

  # @return [Connection, nil]
  def connection_with_credentials
    Connection.transaction do
      conn = connection
      credential_with_options
      conn
    end
  end

  # @return [Connection]
  def connection
    @connection ||= Connection.create(:user => user, :data_source => data_source)
  end

  # @return [Credential]
  def credential_with_options
    Credential.create_with_options(user, connection, serialized_token)
  end

  # @return [Hash]
  def serialized_token
    puller = Puller::Client.for_data_source(data_source).new
    puller.code = code
    puller.serialize_token
  end
end
