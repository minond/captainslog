require "test_helper"

class ProcessorClientTest < ActiveSupport::TestCase
  test "it makes an http post request to the configured url" do
    poster = TestPoster.new
    client = Processor::Client.new(poster, :address => "http://addr")
    client.request(Processor::Request.new)
    assert_equal URI("http://addr"), poster[0][:uri]
  end

  TestResponse =
    Struct.new(:code, :body)

  class TestPoster
    attr_reader :res, :err, :calls

    def initialize(res = TestResponse.new(200, "{}"), err = nil)
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
