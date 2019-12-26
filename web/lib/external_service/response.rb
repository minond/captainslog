module ExternalService
  # Response is a thin wrapper around an actual HTTP response. This class and
  # its children define helper methods that a client class can rely on for
  # accessing the status and contents of a response.
  class Response
    # @param [Net::HTTPResponse] res
    def initialize(res)
      @res = res
    end

    # # @return [Boolean]
    def ok?
      code == "200"
    end

    # @return [String]
    def code
      res.code
    end

    # @return [String]
    def body
      res.body
    end

  private

    attr_reader :res

    # @return [Hash]
    def parsed_body
      @parsed_body ||= JSON.parse(res.body)
    end
  end
end
