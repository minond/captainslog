module ExternalService
  # Base runner class for external service integrations. Depends on a `reponse`
  # method being implemented by the child class.
  class Runner
    # Initializes the child runner class and executes it.
    #
    # @param [Any] *args
    # @return [Any]
    def self.run(*args)
      new(*args).run
    end

    # @param [ExternalService::Client] client
    def initialize(client)
      @client = client
    end

  private

    attr_reader :client

    # @return [ExternalService::Response]
    def response
      @response ||= client.request(request)
    end

    # @return [ExternalService::Request]
    def request
      raise NotImplementedError.new
    end
  end
end
