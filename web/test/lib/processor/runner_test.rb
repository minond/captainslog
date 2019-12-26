require "test_helper"

class ProcessorRunnerTest < ActiveSupport::TestCase
  test "it raises an error when there is a processing error" do
    response = ProcessorTest::HTTPResponse.new("400", "processing error")
    runner = ProcessorTest.new_runner_with_response(response)
    assert_raises(Processor::ProcessingError) { runner.process }
  end

  test "returns processing response text" do
    response, expected_text, expected_data = ProcessorTest.new_sample_response
    runner = ProcessorTest.new_runner_with_response(response)
    returned_text, returned_data = runner.process
    assert_equal expected_text, returned_text
  end

  test "returns processing response data" do
    response, expected_text, expected_data = ProcessorTest.new_sample_response
    runner = ProcessorTest.new_runner_with_response(response)
    returned_text, returned_data = runner.process
    assert_equal expected_data["a"], returned_data["a"]
  end

  test "returns system data" do
    response, _, _ = ProcessorTest.new_sample_response
    runner = ProcessorTest.new_runner_with_response(response)
    _, data = runner.process

    assert data[:_processed]
    assert data[:_processed_at]
    assert data[:_created_at]
    assert data[:_updated_at]
  end
end
