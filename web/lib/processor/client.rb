module Processor
  class Client
    # @param [Hash] config
    # @param [HTTPPostClient] poster, defaults to `Net::HTTP`
    def initialize(config = Rails.application.config.processor, poster = Net::HTTP)
      @config = config
      @poster = poster
    end

    # @raise [Processor::Error]
    # @param [Processor::Request] req
    # @return [Processor::Response]
    def request(req)
      res = post(uri, req)
      ok?(res) ? response(res) : error(res)
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
    # @return [Processor::Error]
    def error(res)
      Processor::Error.new("bad response: [#{res.code}] #{res.body}")
    end

    # @param [Net::HTTPResponse] res
    # @return [Hash]
    def parsed_response_data(res)
      @parsed_response_data ||= JSON.parse(res.body)["data"]
    end
  end
end
