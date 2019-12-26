module Processor
  class Client
    # @param [Hash] config
    def initialize(config = Rails.application.config.processor)
      @config = config
    end

    # @return [Processor::Response, Processor::Error]
    def request(req)
      res = begin
              Net::HTTP.post(uri, req.to_json)
            rescue StandardError => e
              return Processor::Error.new("unable to make request: #{e}")
            end

      ok?(res) ? response(res) : error(res)
    end

  private

    attr_reader :config

    # @return [URI]
    def uri
      URI(config[:address])
    end

    # @param [Net::HTTPResponse] res
    # @return [Boolean]
    def ok?(res)
      res.code == "200"
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