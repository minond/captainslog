class SetupConnectionAuth
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

    create_connection_with_credentials
  end

private

  attr_reader :user, :data_source, :code

  def validate
    errors.add :missing_user, "a user is required" unless user.present?
    errors.add :missing_code, "an authentication code is required" unless code.present?
  end

  # @return [Connection, nil]
  def create_connection_with_credentials
    Connection.transaction do
      conn = connection
      create_credential_with_options
      conn
    end
  end

  # @return [Connection]
  def connection
    @connection ||= Connection.create(:user => user, :data_source => data_source)
  end

  # @return [Credential]
  def create_credential_with_options
    Credential.create_with_options(user, connection, credential_options)
  end

  # @return [Hash]
  def credential_options
    client = DataSource::Client.for_data_source(data_source).new
    client.code = code
    client.credential_options
  end
end
