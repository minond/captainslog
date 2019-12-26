require "net/http"
require "uri"

class Processor
  class Error < StandardError; end

  Request = Struct.new(:book_id, :text, :keyword_init => true)
  Response = Struct.new(:text, :data, :keyword_init => true)

  class Client
    # @param [Hash] config
    def initialize(config = Rails.application.config.processor)
      @config = config
    end

    # @return [Net::HTTPResponse]
    def request(req)
      res = begin
              Net::HTTP.post(uri, req.to_json)
            rescue => err
              return Processor::Error.new("unable to make request: #{err}")
            end

      ok?(res) ? response(res) : error(res)
    end

  private

    # @return [URI]
    def uri
      URI(config[:address])
    end

    # @param [Net::HTTPResponse] res
    # @return [Boolean]
    def ok?(res)
      res.code == "200"
    end

    # @param [Net::HTTPResponse] res
    # @return [Processor::Response]
    def response(res)
      Processor::Response.new(:text => data(res)["text"],
                              :data => data(res)["data"] || {})
    end

    # @param [Net::HTTPResponse] res
    # @return [Processor::Error]
    def error(res)
      Processor::Error.new("bad response: [#{res.code}] #{res.body}")
    end

    # @param [Net::HTTPResponse] res
    # @return [Hash]
    def data(res)
      @data ||= JSON.parse(res.body)["data"]
    end

    attr_reader :config
  end

  # @param [Entry] entry
  # @return [Hash]
  def self.process(entry)
    Processor.new(entry).process
  end

  # @param [Entry] entry
  def initialize(entry)
    @entry = entry
  end

  # Runs entry through external text processor. Also generates standard system
  # data that it tags to the entry.
  #
  # @return [Tuple<String, Hash>]
  def process
    [processed_text, processed_fields.merge(system_fields)]
  end

private

  attr_reader :entry

  # Processes entry text through external processor service to generate processed text.
  #
  # @return [Hash]
  def processed_text
    entry.original_text
  end

  # Processes entry text through external processor service to generate extracted data.
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
