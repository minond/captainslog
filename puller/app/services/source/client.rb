class Source::Client
  include OpenTracing::Instrumented
  include Source::Client::Configurable

  # @return [Symbol]
  def self.source
    name.demodulize.underscore.to_sym
  end

  # @param [Hash] options
  def initialize(options = {})
    client(options)
  end

  # Path to page where user can start the authentication process for this
  # source.
  #
  # @param [Connection, nil] connection
  # @return [String]
  def auth_url(_connection = nil)
    raise NotImplementedError, "#auth_url is not implemented"
  end

  # Path to page where user can start the authentication process for this
  # source.
  #
  # @return [String]
  def base_auth_url
    raise NotImplementedError, "#base_auth_url is not implemented"
  end

  # @return [Hash]
  def credential_options
    raise NotImplementedError, "#credential_options is not implemented"
  end

  # @return [Boolean]
  def oauth_authenticated?
    self.class < OauthAuthenticated
  end

  # @return [Boolean]
  def token_authenticated?
    self.class < TokenAuthenticated
  end

  # @return [Boolean]
  def input?
    self.class < Input
  end

  # @return [Boolean]
  def output?
    self.class < Output
  end
end
