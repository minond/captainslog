class CreateConnectionAuth
  prepend SimpleCommand

  # @param [User] user
  # @param [Symbol] source
  # @param [String] auth_code
  def initialize(user, source, auth_code)
    @user = user
    @source = source
    @auth_code = auth_code
  end

  # @return [Connection, nil]
  def call
    validate
    return unless errors.empty?

    create_connection_with_credentials
  end

private

  attr_reader :user, :source, :auth_code

  def validate
    errors.add :missing_user, "a user is required" unless user.present?
    errors.add :missing_code, "an authentication code is required" unless auth_code.present?
  end

  # @return [Connection, nil]
  def create_connection_with_credentials
    Connection.create_with_credentials(connection_attrs, credentials_hash)
  end

  # @return [Hash]
  def connection_attrs
    { :user => user, :source => source }
  end

  # @return [Hash]
  def credentials_hash
    Source.credentials_for_source(source, auth_code)
  end
end
