module Processor
  class Response
    # @param [Net::HTTPResponse] res
    def initialize(res)
      @res = res
    end

    # # @return [Boolean]
    def ok?
      res.code == "200"
    end

    # @return [String]
    def text
      parsed_data["text"]
    end

    # @return [Hash, Nil]
    def data
      parsed_data["data"]
    end

  private

    attr_reader :res

    # @return [Hash]
    def parsed_data
      @parsed_data ||= JSON.parse(res.body)["data"]
    end
  end
end
