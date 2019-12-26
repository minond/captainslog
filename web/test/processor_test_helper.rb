module ProcessorTest
  HTTPResponse =
    Struct.new(:code, :body)

  SAMPLE_RESULTS = {
    :data => {
      :text => "hi",
      :data => {}
    }
  }.freeze

  SAMPLE_OK_RESPONSE =
    ProcessorTest::HTTPResponse.new("200", JSON.dump(ProcessorTest::SAMPLE_RESULTS))

  class Poster
    attr_reader :res, :err, :calls

    def initialize(res = SAMPLE_OK_RESPONSE, err = nil)
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

  # @param [String] text
  # @param [Hash] data
  # @return [ProcessorTest::HTTPResponse]
  def self.ok_response(text, data)
    response = {
      :data => {
        :text => text,
        :data => data
      }
    }

    ProcessorTest::HTTPResponse.new("200", response.to_json)
  end
end
