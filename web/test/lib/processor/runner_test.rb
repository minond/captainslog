require "test_helper"

class ProcessorRunnerTest < ActiveSupport::TestCase
  test "it raises an error when there is a processing error" do
    response = ExternalServiceTestHelper::HTTPResponse.new("400", "processing error")
    runner = ProcessorTestHelper.new_runner_with_response(response)
    assert_raises(Processor::ProcessingError) { runner.run }
  end

  test "returns processing response text" do
    response, expected_text, _expected_data = ProcessorTestHelper.new_sample_response
    runner = ProcessorTestHelper.new_runner_with_response(response)
    returned_text, _returned_data = runner.run
    assert_equal expected_text, returned_text
  end

  test "returns processing response data" do
    response, _expected_text, expected_data = ProcessorTestHelper.new_sample_response
    runner = ProcessorTestHelper.new_runner_with_response(response)
    _returned_text, returned_data = runner.run
    assert_equal expected_data["a"], returned_data["a"]
  end

  test "returns system data" do
    response, _expected_text, _expected_data = ProcessorTestHelper.new_sample_response
    runner = ProcessorTestHelper.new_runner_with_response(response)
    _returned_text, returned_data = runner.run

    assert returned_data[:_processed]
    assert returned_data[:_processed_at]
    assert returned_data[:_created_at]
    assert returned_data[:_updated_at]
  end
end
