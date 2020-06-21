class Service::Captainslog < Service::Client
  include Target
  include TokenAuthenticated

  attr_accessor :token

  config_from :captainslog

  ENTRY_BULK_CREATE_RECORD_LIMIT = 100

  # @param [Hash] options
  def initialize(options = {})
    @token = options.with_indifferent_access[:token]
  end

  # @return [String]
  def base_auth_url
    config[:application_uri]
  end

  # @return [Hash]
  def credential_options
    { :token => token }
  end

  # @return [Array<Service::Resource>]
  def available_target_resources
    books.map do |book|
      Service::Resource.new(book["id"], self.class.service, book["name"])
    end
  end

  # @param [Array<Service::Record>] records
  # @param [Service::Resource] resource
  def push(records, resource)
    each_entry_payload(records) do |texts, times|
      bulk_create_entries(texts, times, resource)
    end
  end

private

  # @return [Hash]
  def books
    make_request(:get, "/api/v1/books")
  end

  # @param [Array<Text>] texts
  # @param [Array<Integer>] times
  # @param [Service::Resource] resource
  def bulk_create_entries(texts, times, resource)
    make_request(:post, "/api/v1/books/#{resource.id}/entries", :texts => texts,
                                                                :times => times)
  end

  # @param [Array<Service::Record>] records
  # @yieldparam [Array<Service::Record>] records
  def each_entry_payload(records)
    records.each_slice(ENTRY_BULK_CREATE_RECORD_LIMIT) do |subrecords|
      texts, times = subrecords.each_with_object([[], []]) do |record, acc|
        acc.first << record.text
        acc.second << record.datetime.to_i
      end

      yield(texts, times)
    end
  end

  # @param [Symbol] method
  # @param [String] path
  # @param [Hash] payload
  # @return [Hash]
  def make_request(method, path, payload = nil)
    make(request(method, path, payload))
  end

  # @param [Net::HTTPRequest] req
  # @return [Hash]
  def make(req)
    res = client.request(req)
    JSON.parse(res.body || "{}")
  end

  # @param [Symbol] method
  # @param [String] path
  # @param [Hash] payload
  # @return [Net::HTTPRequest]
  def request(method, path, payload = nil)
    req = case method
          when :get
            Net::HTTP::Get.new(path)
          when :post
            Net::HTTP::Post.new(path)
          end

    req.body = payload.to_json if payload.present?
    req.set_content_type("application/json") if payload.is_a?(Hash)
    req["Authorization"] = token
    req
  end

  # @param [Hash] options
  # @return [Net::HTTP]
  def client(options = {})
    @client ||= begin
                  conf = config(options)
                  uri = URI.parse(conf[:application_uri])
                  Net::HTTP.new(uri.host, uri.port)
                end
  end
end
