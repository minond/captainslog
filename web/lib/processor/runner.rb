require "net/http"
require "uri"

module Processor
  class Runner
    # @param [Entry] entry
    def initialize(entry)
      @entry = entry
    end

    # Runs entry through external text processor. Also generates standard
    # system data that it tags to the entry.
    #
    # @return [Tuple<String, Hash>]
    def process
      [processed_text, processed_fields.merge(system_fields)]
    end

  private

    attr_reader :entry

    # Processes entry text through external processor service to generate
    # processed text.
    #
    # @return [Hash]
    def processed_text
      entry.original_text
    end

    # Processes entry text through external processor service to generate
    # extracted data.
    #
    # @return [Hash]
    def processed_fields
      # req = Request.new(:book_id => entry.book.id,
      #                   :text => entry.original_text)
      {}
    end

    # @return [Hash]
    def system_fields
      {
        :_processed => true,
        :_processed_at => Time.now.utc.to_i,
        :_created_at => entry.created_at.to_i,
        :_updated_at => entry.updated_at.to_i
      }
    end
  end
end
