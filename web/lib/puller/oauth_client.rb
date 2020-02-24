class Puller::OauthClient < Puller::Client
  # Generates an authentication URL that grants an oauth code.
  #
  # @param [Hash] state
  # @return [String]
  def auth_url(_state)
    raise NotImplementedError.new, "#auth_url is not implemented"
  end

  # Oauth code setter. Setting the code will trigger the Fitbit API client to
  # load an oauth token which it will continue to use in subseqent API calls.
  #
  # @param [String] code
  def code=(_code)
    raise NotImplementedError.new, "#code= is not implemented"
  end

  # @return [Hash]
  def serialize_token
    raise NotImplementedError.new, "#serialize_token is not implemented"
  end
end
