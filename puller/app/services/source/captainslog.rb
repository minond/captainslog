class Source::Captainslog < Source::Client
  include Output
  include TokenAuthenticated

  attr_accessor :token

  config_from :captainslog

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

  # @return [Array<Output::Destination>]
  def available_output_destinations
    books.map do |book|
      Output::Destination.new(:id => book["id"], :label => book["name"])
    end
  end

private

  # @return [Hash]
  def books
    make(request(:get, "/api/v1/books"))
  end

  # @param [Net::HTTPRequest] req
  # @return [Hash]
  def make(req)
    res = client.request(req)
    JSON.parse(res.body)
  end

  # @param [Symbol] method
  # @param [String] path
  # @return [Net::HTTPRequest]
  def request(method, path)
    req = case method
          when :get
            Net::HTTP::Get.new(path)
          end

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
