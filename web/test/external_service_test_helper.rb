module ExternalServiceTestHelper
  HTTPResponse =
    Struct.new(:code, :body)

  # ExternalServiceTestHelper::Poster meets Net::HTTP.post interface. An
  # instance of this mocked class is used when spying on how a client makes
  # requests and when testing how it handles different responses.
  class Poster
    # @param [HTTPResponse] res
    # @param [Error] err, defaults to nil
    def initialize(res, err = nil)
      @res = res
      @err = err
      @calls = []
    end

    # @param [URI] uri
    # @param [String] body
    # @return [HTTPResponse]
    def post(uri, body)
      @calls << { :uri => uri, :body => body }
      raise err if err

      res
    end

    # @param [Integer] index
    # @return [Hash]
    def [](index)
      calls[index]
    end

  private

    attr_reader :res, :err, :calls
  end

  class DummyRunner < ExternalService::Runner
    # rubocop:disable Style/ClassVars
    @@ran = false
    # rubocop:enable Style/ClassVars

    def self.ran
      @@ran
    end

    def run
      # rubocop:disable Style/ClassVars
      @@ran = true
      # rubocop:enable Style/ClassVars
    end

    def response
      super
    end
  end
end
