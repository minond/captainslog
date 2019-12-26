module ProcessorTest
  HTTPResponse =
    Struct.new(:code, :body)

  class Poster
    attr_reader :res, :err, :calls

    def initialize(res = ProcessorTest.ok_response, err = nil)
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

  # @param [String] text, defaults to an empty string
  # @param [Hash] data, defaults to an empty hash
  # @return [ProcessorTest::HTTPResponse]
  def self.ok_response(text = "", data = {})
    response = {
      :data => {
        :text => text,
        :data => data
      }
    }

    ProcessorTest::HTTPResponse.new("200", response.to_json)
  end

  # @param [ProcessorTest::HTTPResponse] http_res
  # @return [Processor::Runner]
  def self.new_runner_with_response(http_res)
    poster = ProcessorTest::Poster.new(http_res)
    client = Processor::Client.new(poster)
    Processor::Runner.new(FactoryBot.create(:entry), client)
  end

  # Creates a succssful test http response and returns this along with the used
  # text and data.
  #
  # @return [Tuple<ProcessorTest::HTTPResponse, String, Hash>]
  def self.new_sample_response
    expected_text = "hi"
    expected_data = {"a" => "b"}
    response = ProcessorTest.ok_response(expected_text, expected_data)
    [response, expected_text, expected_data]
  end
end
