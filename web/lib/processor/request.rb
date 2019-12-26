module Processor
  class Request
    # @param [Entry] entry
    def initialize(entry)
      @entry = entry
    end

    # @param [Any] *args, defined to meet requirements for `JSON.generate`
    # @return [String]
    def to_json(*_args)
      to_hash.to_json
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
