module ProcessorTest
  Response =
    Struct.new(:code, :body)

  SAMPLE_RESULTS = {
    :data => {
      :text => "hi",
      :data => {}
    }
  }.freeze

  SAMPLE_OK_RESPONSE =
    ProcessorTest::Response.new("200", JSON.dump(ProcessorTest::SAMPLE_RESULTS))

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
end
