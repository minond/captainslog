module Processor
  class Client
    # @param [HTTPPostClient] poster, defaults to `Net::HTTP`. This should be
    #   anything that responds to `post` with a uri and request body. This is
    #   what we'll be using ot make the actual POST request.
    # @param [Hash] config. This should be a hash with a `:address` item in it.
    #   This is where we'll be making a post request to.
    def initialize(poster = Net::HTTP, config = Rails.application.config.processor)
      @poster = poster
      @config = config
    end

    # @raise [Processor::RequestError]
    # @param [Processor::Request] req
    # @return [Processor::Response]
    def request(req)
      Processor::Response.new(poster.post(uri, req.to_json))
    rescue StandardError => e
      raise Processor::RequestError, "unable to make request: #{e}"
    end

  private

    attr_reader :config, :poster

    # @return [URI]
    def uri
      URI(config[:address])
    end
  end
end
