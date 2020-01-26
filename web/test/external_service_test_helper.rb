module ExternalServiceTestHelper
  HTTPResponse =
    Struct.new(:code, :body)

  class Poster
    attr_reader :res, :err, :calls

    def initialize(res = ProcessorTestHelper.new_ok_response, err = nil)
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
