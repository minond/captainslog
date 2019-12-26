require "net/http"
require "uri"

module Processor
  class Runner
    # @param [Entry] entry
    def initialize(entry)
      @entry = entry
      @client = Processor::Client.new
    end

    # Runs entry through external text processor. Also generates standard
    # system data that it tags to the entry.
    #
    # @raise [Processor::Error]
    # @return [Tuple<String, Hash>]
    def process
      fail response if response.is_a?(Processor::Error)
      [processed_text, processed_fields.merge(system_fields)]
    end

  private

    attr_reader :entry, :client

    # @return [Processor::Request]
    def request
      Processor::Request.new(:book_id => entry.book_id,
                             :text => entry.original_text)
    end

    # @return [Processor::Response]
    def response
      @response ||= client.request(request)
    end

    # Processes entry text through external processor service to generate
    # processed text.
    #
    # @return [Hash]
    def processed_text
      response.text
    end

    # Processes entry text through external processor service to generate
    # extracted data.
    #
    # @return [Hash]
    def processed_fields
      response.data
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
