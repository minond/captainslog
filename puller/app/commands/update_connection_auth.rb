class UpdateConnectionAuth
  prepend SimpleCommand

  # @param [User] user
  # @param [Connection] connection
  # @param [String] code
  def initialize(user, connection, code)
    @user = user
    @connection = connection
    @code = code
  end

  # @return [Connection]
  def call
    validate
    return unless errors.empty?

    create_credentials
    connection
  end

private

  attr_reader :user, :connection, :code

  def validate
    errors.add :missing_user, "a user is required" unless user.present?
    errors.add :missing_code, "an authentication code is required" unless code.present?
    errors.add :missing_connection, "a connection is required" unless connection.present?
  end

  # @return [Credential]
  def create_credentials
    Credential.create_with_options(connection, credentials_hash)
  end

  # @return [Hash]
  def credentials_hash
    Source::Client.credentials_for_source(connection.source, code)
  end
end