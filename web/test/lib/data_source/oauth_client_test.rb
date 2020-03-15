require "test_helper"

class DataSourceOauthClientTest < ActiveSupport::TestCase
  test "needs code= override" do
    assert_raises(NotImplementedError) { DataSource::OauthClient.new.code = "123" }
  end
end
