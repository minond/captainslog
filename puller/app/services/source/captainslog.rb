class Source::Captainslog < Source::Client
  include Source::Output

  # @param [Hash] options
  def initialize(options = {})
    @token = options.with_indifferent_access[:token]
  end

  # Path to page where user can start the authentication process for this
  # source.
  #
  # @param [Connection, nil] connection
  # @return [String]
  def auth_url(connection = nil)
    state = "?state=#{self.class.encode_state(connection)}"
    callback = URI.encode_www_form_component(config[:redirect_uri] + state)
    "#{base_auth_url}?callback=#{callback}"
  end

  # @return [String]
  def base_auth_url
    config[:application_uri]
  end

  # @param [String] code
  def code=(code)
    @token = code
  end

  # @return [Hash]
  def credential_options
    { :token => token }
  end

private

  attr_accessor :token

  # @return [Hash]
  def config
    @config ||= ::Rails.application.config.captainslog.with_indifferent_access
  end
end
