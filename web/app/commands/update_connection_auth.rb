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

    create_credential_with_options
    reset_connection_last_update
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
  def create_credential_with_options
    Credential.create_with_options(user, connection, credential_options)
  end

  def reset_connection_last_update
    connection.update(:last_update_job_id => nil,
                      :last_update_attempted_at => nil)
  end

  # @return [Hash]
  def credential_options
    client = DataSource::Client.for_data_source(connection.data_source).new
    client.code = code
    client.credential_options
  end
end
