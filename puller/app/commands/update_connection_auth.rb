class UpdateConnectionAuth
  prepend SimpleCommand

  # @param [User] user
  # @param [Connection] connection
  # @param [String] auth_code
  def initialize(user, connection, auth_code)
    @user = user
    @connection = connection
    @auth_code = auth_code
  end

  # @return [Connection]
  def call
    validate
    return unless errors.empty?

    create_credentials
    connection
  end

private

  attr_reader :user, :connection, :auth_code

  def validate
    errors.add :missing_user, "a user is required" unless user.present?
    errors.add :missing_code, "an authentication code is required" unless auth_code.present?
    errors.add :missing_connection, "a connection is required" unless connection.present?
  end

  # @return [Credential]
  def create_credentials
    Credential.create_with_options(connection, credentials_hash)
  end

  # @return [Hash]
  def credentials_hash
    Service.credentials_for_service(connection.service, auth_code)
  end
end
