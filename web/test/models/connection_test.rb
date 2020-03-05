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

  test "schedule_data_pull_backfill" do
    assert_not Job.first
    connection.schedule_data_pull_backfill
    assert_equal "connection_data_pull_backfill", Job.first.kind
  end

  test "schedule_data_pull_standard" do
    assert_not Job.first
    connection.schedule_data_pull_standard
    assert_equal "connection_data_pull_standard", Job.first.kind
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
