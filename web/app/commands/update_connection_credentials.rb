class UpdateConnectionCredentials
  prepend SimpleCommand

  # @param [Connection] connection
  def initialize(connection)
    @connection = connection
  end

  # @return [Connection, nil]
  def call
    update_credential_with_options
  end

private

  attr_reader :connection

  delegate :user, :to => :connection, :private => true
  delegate :client, :to => :connection, :private => true
  delegate :credential_options, :to => :client, :private => true

  # @return [Credential]
  def update_credential_with_options
    Credential.create_with_options(user, connection, credential_options)
  end

  # @return [Hash]
  def credential_options
    client.credential_options
  end

  # @return [DataSource::Client]
  def client
    connection.client
  end

  # @return [User]
  def user
    connection.user
  end
end
