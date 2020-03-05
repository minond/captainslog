require "test_helper"

class ConnectionTest < ActiveSupport::TestCase
  test "save happy path" do
    assert connection.save
  end

  test "client without credentials" do
    assert_raises(Connection::MissingCredentialsError) { connection.client }
  end

  test "client with credentials" do
    Credential.create_with_options(user, connection, {})
    assert connection.client
  end

private

  def connection
    @connection ||= Connection.new(:book => book,
                                   :user => user,
                                   :data_source => :fitbit)
  end

  def user
    @user ||= create(:user)
  end

  def book
    @book ||= create(:book, :user => user)
  end
end
