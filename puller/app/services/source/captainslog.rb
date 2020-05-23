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
end
