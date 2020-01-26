require "test_helper"

class ProcessorResponseTest < ActiveSupport::TestCase
  test "#text" do
    response = ProcessorTestHelper.new_ok_response("text", {})
    assert_equal "text", Processor::Response.new(response).text
  end

  test "#data" do
    data = { "a" => "b" }
    response = ProcessorTestHelper.new_ok_response("text", data)
    assert_equal data, Processor::Response.new(response).data
  end
end
