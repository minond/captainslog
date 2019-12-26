require "test_helper"

class ProcessorResponseTest < ActiveSupport::TestCase
  test "#ok?" do
    assert Processor::Response.new(ProcessorTest::HTTPResponse.new("200")).ok?
    assert_not Processor::Response.new(ProcessorTest::HTTPResponse.new).ok?
    assert_not Processor::Response.new(ProcessorTest::HTTPResponse.new("400")).ok?
  end

  test "#code" do
    assert_equal "201", Processor::Response.new(ProcessorTest::HTTPResponse.new("201")).code
  end

  test "#body" do
    assert_equal "bod", Processor::Response.new(ProcessorTest::HTTPResponse.new("201", "bod")).body
  end

  test "#text" do
    response = ProcessorTest.new_ok_response("text", {})
    assert_equal "text", Processor::Response.new(response).text
  end

  test "#data" do
    data = { "a" => "b" }
    response = ProcessorTest.new_ok_response("text", data)
    assert_equal data, Processor::Response.new(response).data
  end
end
