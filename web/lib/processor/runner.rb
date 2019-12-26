module Processor
  class Runner
    # @raise [Processor::ProcessingError]
    # @raise [Processor::RequestError]
    # @param [Entry] entry
    # @return [Tuple<String, Hash>]
    def self.process(entry)
      new(entry).process
    end

    # @param [Entry] entry
    # @param [Processor::Client] client, defaults to a new client
    def initialize(entry, client = Processor::Client.new)
      @entry = entry
      @client = client
    end

    # Runs entry through external text processor. Also generates standard
    # system data that it tags to the entry.
    #
    # @raise [Processor::ProcessingError]
    # @raise [Processor::RequestError]
    # @return [Tuple<String, Hash>]
    def process
      raise Processor::ProcessingError, "bad response: [#{response.code}] #{response.body}" unless response.ok?

      [processed_text, processed_data.merge(system_data)]
    end

  private

    attr_reader :entry, :client

    # @return [Processor::Request]
    def request
      Processor::Request.new(entry)
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
    def processed_data
      response.data || {}
    end

    # @return [Hash]
    def system_data
      {
        :_processed => true,
        :_processed_at => Time.now.utc.to_i,
        :_created_at => entry.created_at.to_i,
        :_updated_at => entry.updated_at.to_i
      }
    end
  end
end
