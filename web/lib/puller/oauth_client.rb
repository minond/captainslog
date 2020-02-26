class Puller::OauthClient < Puller::Client
  # Generates an authentication URL that grants an oauth code. This URL
  # includes state which is used to continue the connection setup process.
  #
  # @param [String] slug
  # @return [String]
  def auth_url(slug)
    encoded_state = self.class.encode_state(slug)
    base_auth_url + "&state=#{encoded_state}"
  end

  # Generates an authentication URL that grants an oauth code.
  #
  # @return [String]
  def base_auth_url
    raise NotImplementedError.new, "#base_auth_url is not implemented"
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

  # @param [String] slug
  # @return [String]
  def self.encode_state(slug)
    state = { :slug => slug }
    Base64.urlsafe_encode64(state.to_json)
  end

  # @param [String] encode_state
  # @return [String, nil]
  def self.decode_slug_from_state(encoded_state)
    decoded = Base64.urlsafe_decode64(encoded_state)
    obj = JSON.parse(decoded)
    obj["slug"]
  rescue
    nil
  end
end
