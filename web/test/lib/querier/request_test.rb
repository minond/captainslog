require "test_helper"

class QuerierRequestTest < ActiveSupport::TestCase
  test "#to_hash" do
    expected = { :user_id => 12, :query => "hi there" }
    assert expected, Querier::Request.new(12, "hi there").to_hash
  end

  test "#to_json" do
    expected = "{\"user_id\":12,\"query\":\"hi there\"}"
    assert expected, Querier::Request.new(12, "hi there").to_json
  end
end
