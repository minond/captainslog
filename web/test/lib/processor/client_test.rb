require "test_helper"

class ProcessorClientTest < ActiveSupport::TestCase
  test "it makes an http post request to the configured url" do
    poster = ProcessorTest::Poster.new
    client = Processor::Client.new(poster, :address => "http://addr")
    client.request(Processor::Request.new(create(:entry)))
    assert_equal URI("http://addr"), poster[0][:uri]
  end

  test "it raises any errors from the http request" do
    poster = ProcessorTest::Poster.new(nil, StandardError.new("err"))
    client = Processor::Client.new(poster)
    assert_raises(Processor::RequestError) { client.request(Processor::Request.new(create(:entry))) }
  end

  test "parses data from response when it is successful" do
    client = Processor::Client.new(ProcessorTest::Poster.new)
    response = client.request(Processor::Request.new(create(:entry)))
    assert_equal ProcessorTest::SAMPLE_RESULTS[:data][:text], response.text
    assert_equal ProcessorTest::SAMPLE_RESULTS[:data][:data], response.data
  end
end
