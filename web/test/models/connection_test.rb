require "test_helper"

class ConnectionTest < ActiveSupport::TestCase
  test "save happy path" do
    assert connection.save
  end

  test "client without credentials" do
    assert_raises(Connection::MissingCredentialsError) { connection.client }
  end

  test "client with credentials" do
    conn = connection
    Credential.create_with_options(user, conn, {})
    assert conn.client
  end

  test "schedule_data_pull_backfill" do
    assert_not Job.first
    connection.schedule_data_pull_backfill
    assert_equal "connection_data_pull_backfill", Job.first.kind
  end

  test "schedule_data_pull_standard" do
    assert_not Job.first
    connection.schedule_data_pull_standard
    assert_equal "connection_data_pull_standard", Job.last.kind
  end

  test "schedule_data_pull_standard return previous job when scheduled within 15 min" do
    conn = connection
    conn.save!
    original_job = conn.schedule_data_pull_standard
    same_job = conn.schedule_data_pull_standard
    assert_equal original_job.id, same_job.id
  end

  test "book and connection must be owned by same user" do
    assert_raises(ActiveRecord::RecordInvalid) do
      create(:connection, :user => create(:user),
                          :book => create(:book, :user => create(:user)))
    end
  end

private

  def connection
    Connection.new(:book => book,
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
