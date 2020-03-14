require "test_helper"

class DataSourceClientTest < ActiveSupport::TestCase
  test "state encoding/decoding" do
    user = create(:user)
    book = create(:book, :user => user)
    connection = create(:connection, :user => user, :book => book)
    encoded = DataSource::Client.encode_state(connection)
    connection_id, _rest = DataSource::Client.decode_state(encoded)
    assert connection.id
    assert_equal connection.id, connection_id
  end

  test "needs base_auth_url override for auth_url" do
    assert_raises(NotImplementedError) { DataSource::Client.new.auth_url }
  end

  test "needs base_auth_url override" do
    assert_raises(NotImplementedError) { DataSource::Client.new.base_auth_url }
  end

  test "needs credential_options override" do
    assert_raises(NotImplementedError) { DataSource::Client.new.credential_options }
  end

  test "needs data_pull override" do
    assert_raises(NotImplementedError) { DataSource::Client.new.send(:data_pull, {}) }
  end
end
