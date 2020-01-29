require "test_helper"

class QuerierResponseTest < ActiveSupport::TestCase
  test "#columns" do
    response = QuerierTestHelper.new_ok_response(%w[col1 col2], nil)
    assert_equal %w[col1 col2], Querier::Response.new(response).columns
  end

  test "#results" do
    results = [[{}, {}, {}], [{}, {}, {}]]
    response = QuerierTestHelper.new_ok_response([], results)
    assert_equal results, Querier::Response.new(response).results
  end
end
