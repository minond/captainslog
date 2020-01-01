require "test_helper"

class ProcessorClientTest < ActiveSupport::TestCase
  test "it makes an http post request to the configured url" do
    poster = ProcessorTestHelper::Poster.new
    client = Processor::Client.new(poster, :address => "http://addr")
    client.request(Processor::Request.new(create(:entry)))
    assert_equal URI("http://addr"), poster[0][:uri]
  end

  test "it raises any errors from the http request" do
    poster = ProcessorTestHelper::Poster.new(nil, StandardError.new("err"))
    client = Processor::Client.new(poster)
    assert_raises(Processor::RequestError) { client.request(Processor::Request.new(create(:entry))) }
  end

  test "parses data from response when it is successful" do
    processed_text = "testing"
    processed_data = { "a" => "b" }
    service_response = ProcessorTestHelper.new_ok_response(processed_text, processed_data)
    client = Processor::Client.new(ProcessorTestHelper::Poster.new(service_response))
    response = client.request(Processor::Request.new(create(:entry)))
    assert_equal processed_text, response.text
    assert_equal processed_data, response.data
  end
end
