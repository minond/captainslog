class CreateConnectionAuth
  prepend SimpleCommand

  # @param [User] user
  # @param [Symbol] source
  # @param [String] code
  def initialize(user, source, code)
    @user = user
    @source = source
    @code = code
  end

  # @return [Connection, nil]
  def call
    validate
    return unless errors.empty?

    create_connection_with_credentials
  end

private

  attr_reader :user, :source, :code

  def validate
    errors.add :missing_user, "a user is required" unless user.present?
    errors.add :missing_code, "an authentication code is required" unless code.present?
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
    Source::Client.credentials_for_source(source, code)
  end
end
