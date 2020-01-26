module Querier
  class Request < ExternalService::Request
    # @param [Integer] user_id
    # @param [String] query
    def initialize(user_id, query)
      @user_id = user_id
      @query = query
    end

    # @return [Hash]
    def to_hash
      {
        :user_id => user_id,
        :query => query
      }
    end

  private

    attr_reader :user_id, :query
  end
end
