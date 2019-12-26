module Processor
  class Response < ExternalService::Response
    # @return [String]
    def text
      parsed_body["data"]["text"]
    end

    # @return [Hash, Nil]
    def data
      parsed_body["data"]["data"]
    end
  end
end
