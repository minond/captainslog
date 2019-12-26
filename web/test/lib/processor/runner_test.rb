require "test_helper"

class ProcessorRunnerTest < ActiveSupport::TestCase
  test "it raises an error when there is a processing error" do
    response = ProcessorTest::HTTPResponse.new("400", "processing error")
    runner = ProcessorTest.new_runner_with_response(response)
    assert_raises(Processor::ProcessingError) { runner.process }
  end

  test "returns processing response text" do
    response, expected_text, _expected_data = ProcessorTest.new_sample_response
    runner = ProcessorTest.new_runner_with_response(response)
    returned_text, _returned_data = runner.process
    assert_equal expected_text, returned_text
  end

  test "returns processing response data" do
    response, _expected_text, expected_data = ProcessorTest.new_sample_response
    runner = ProcessorTest.new_runner_with_response(response)
    _returned_text, returned_data = runner.process
    assert_equal expected_data["a"], returned_data["a"]
  end

  test "returns system data" do
    response, _expected_text, _expected_data = ProcessorTest.new_sample_response
    runner = ProcessorTest.new_runner_with_response(response)
    _returned_text, returned_data = runner.process

    assert returned_data[:_processed]
    assert returned_data[:_processed_at]
    assert returned_data[:_created_at]
    assert returned_data[:_updated_at]
  end
end
