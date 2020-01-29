require "test_helper"

class QuerierRunnerTest < ActiveSupport::TestCase
  test "it raises an error when there is a querying error" do
    response = ExternalServiceTestHelper::HTTPResponse.new("400", "processing error")
    runner = QuerierTestHelper.new_runner_with_response(response)
    assert_raises(Querier::QueryingError) { runner.run }
  end

  test "returns columns" do
    response, expected_columns, _expected_results = QuerierTestHelper.new_sample_response
    runner = QuerierTestHelper.new_runner_with_response(response)
    data = runner.run
    assert_equal expected_columns, data[:columns]
  end

  test "returns results" do
    response, _expected_columns, expected_results = QuerierTestHelper.new_sample_response
    runner = QuerierTestHelper.new_runner_with_response(response)
    data = runner.run
    assert_equal expected_results, data[:results]
  end
end
