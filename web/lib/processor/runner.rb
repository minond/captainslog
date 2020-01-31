module Processor
  class Runner < ExternalService::Runner
    # @param [Entry] entry
    # @param [Processor::Client] client, defaults to a new client
    def initialize(entry, client = Processor::Client.new)
      @entry = entry
      super(client)
    end

    # Runs entry through external text processor. Also generates standard
    # system data that it tags to the entry.
    #
    # @raise [Processor::ProcessingError]
    # @raise [Processor::RequestError]
    # @return [Tuple<String, Hash>]
    def run
      raise Processor::ProcessingError, "bad response: [#{response.code}] #{response.body}" unless response.ok?

      [text, data]
    end

  private

    attr_reader :entry

    # @return [Processor::Request]
    def request
      Processor::Request.new(entry)
    end

    # Processes entry text through external processor service to generate
    # processed text.
    #
    # @return [Hash]
    def text
      response.text
    end

    # Processes entry text through external processor service to generate
    # extracted data. This will also inject metadata field into the response.
    #
    # @return [Hash]
    def data
      (response.data || {}).merge(system_data)
    end

    def system_data
      {
        :_processed => true,
        :_processed_at => Time.now.utc.to_i,
        :_collected_at => entry.collection.datetime.to_i,
        :_created_at => entry.created_at.to_i,
        :_updated_at => entry.updated_at.to_i
      }
    end
  end
end
