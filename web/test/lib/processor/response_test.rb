require "test_helper"

class ProcessorResponseTest < ActiveSupport::TestCase
  test "#ok?" do
    assert Processor::Response.new(TestResponse.new("200")).ok?
    assert_not Processor::Response.new(TestResponse.new).ok?
    assert_not Processor::Response.new(TestResponse.new("400")).ok?
  end

  test "#code" do
    assert_equal "201", Processor::Response.new(TestResponse.new("201")).code
  end

  test "#body" do
    assert_equal "bod", Processor::Response.new(TestResponse.new("201", "bod")).body
  end

  test "#text" do
    text = "text"
    results = { :data => { :text => text } }
    response = TestResponse.new("200", results.to_json)
    assert_equal text, Processor::Response.new(response).text
  end

  test "#data" do
    data = { "a" => "b" }
    results = { :data => { :data => data } }
    response = TestResponse.new("200", results.to_json)
    assert_equal data, Processor::Response.new(response).data
  end

  TestResponse =
    Struct.new(:code, :body)
end
