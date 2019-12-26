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

    # @raise [Processor::Error]
    # @param [Processor::Request] req
    # @return [Processor::Response]
    def request(req)
      res = post(uri, req)
      raise Processor::Error, "bad response: [#{res.code}] #{res.body}" unless ok?(res)

      response(res)
    end

  private

    attr_reader :config, :poster

    # @return [URI]
    def uri
      URI(config[:address])
    end

    # @param [Net::HTTPResponse] res
    # @return [Boolean]
    def ok?(res)
      res.code == "200"
    end

    # @raise [Processor::Error]
    # @param [URI] uri
    # @param [Processor::Request] req
    # @return [Net::HTTPResponse] res
    def post(uri, req)
      poster.post(uri, req.to_json)
    rescue StandardError => e
      raise Processor::Error, "unable to make request: #{e}"
    end

    # @param [Net::HTTPResponse] res
    # @return [Processor::Response]
    def response(res)
      data = parsed_response_data(res)
      Processor::Response.new(:text => data["text"],
                              :data => data["data"] || {})
    end

    # @param [Net::HTTPResponse] res
    # @return [Hash]
    def parsed_response_data(res)
      @parsed_response_data ||= JSON.parse(res.body)["data"]
    end
  end
end
