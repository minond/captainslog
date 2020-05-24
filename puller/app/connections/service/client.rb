class Service::Client
  include OpenTracing::Instrumented
  include Configurable
  include Iterators

  # @return [Symbol]
  def self.source
    name.demodulize.underscore.to_sym
  end

  # @param [Hash] options
  def initialize(options = {})
    client(options)
  end

  # Path to page where user can start the authentication process for this
  # service.
  #
  # @param [Connection, nil] connection
  # @return [String]
  def auth_url(_connection = nil)
    raise NotImplementedError, "#auth_url is not implemented"
  end

  # Path to page where user can start the authentication process for this
  # service.
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
  def source?
    self.class < Source
  end

  # @return [Boolean]
  def target?
    self.class < Target
  end
end
