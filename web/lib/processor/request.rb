module Processor
  class Request < ExternalService::Request
    # @param [Entry] entry
    def initialize(entry)
      @entry = entry
    end

    # @return [Hash]
    def to_hash
      {
        :book_id => entry.book_id,
        :text => entry.original_text
      }
    end

  private

    attr_reader :entry
  end
end
