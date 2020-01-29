module Querier
  class Runner < ExternalService::Runner
    # @param [Integer] user_id
    # @param [String] query
    # @param [Querier::Client] client, defaults to a new client
    def initialize(user_id, query, client = Querier::Client.new)
      @user_id = user_id
      @query = query
      super(client)
    end

    # @raise [Querier::QueryingError]
    # @raise [Querier::RequestError]
    # @return [Hash]
    def run
      raise Querier::QueryingError, "bad response: [#{response.code}] #{response.body}" unless response.ok?

      {
        :columns => response.columns,
        :results => response.results
      }
    end

  private

    attr_reader :user_id, :query

    # @return [Querier::Request]
    def request
      Querier::Request.new(user_id, query)
    end
  end
end
