module Querier
  class Response < ExternalService::Response
    # @return [Array<String>]
    def columns
      parsed_body["data"]["columns"]
    end

    # @return [Array<Array<Hash>>]
    def results
      parsed_body["data"]["results"]
    end
  end
end
