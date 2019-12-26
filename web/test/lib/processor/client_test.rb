require "test_helper"

class ProcessorClientTest < ActiveSupport::TestCase
  test "it makes an http post request to the configured url" do
    poster = TestPoster.new
    client = Processor::Client.new(poster, :address => "http://addr")
    client.request(Processor::Request.new)
    assert_equal URI("http://addr"), poster[0][:uri]
  end

  test "it raises any errors from the http request" do
    poster = TestPoster.new(nil, StandardError.new("err"))
    client = Processor::Client.new(poster)
    assert_raises(Processor::RequestError) { client.request(Processor::Request.new) }
  end

  test "it raises an error when the http request succeeds but processing fails" do
    poster = TestPoster.new(TestResponse.new("400", "bad request"))
    client = Processor::Client.new(poster)
    assert_raises(Processor::ProcessingError) { client.request(Processor::Request.new) }
  end

  test "parses data from response when it is successful" do
    client = Processor::Client.new(TestPoster.new)
    response = client.request(Processor::Request.new)
    assert_equal SampleResponse[:data][:text], response.text
    assert_equal SampleResponse[:data][:data], response.data
  end

  SampleResponse =
    {
      :data => {
        :text => "hi",
        :data => {}
      }
    }

  TestResponse =
    Struct.new(:code, :body)

  class TestPoster
    attr_reader :res, :err, :calls

    def initialize(res = TestResponse.new("200", JSON.dump(SampleResponse)), err = nil)
      @res = res
      @err = err
      @calls = []
    end

    def post(uri, body)
      @calls << { :uri => uri, :body => body }
      raise err if err

      res
    end

    def [](index)
      calls[index]
    end
  end
end
