module Source::Client::OauthAuthenticated
  extend extend ActiveSupport::Concern

  # Oauth code setter. Each client may handle this as needed.
  #
  # @param [String] code
  def code=(_code)
    raise NotImplementedError, "#code= is not implemented"
  end

  # Path to page where user can start the authentication process for this
  # source.
  #
  # @param [Connection, nil] connection
  # @return [String]
  def auth_url(connection = nil)
    base_auth_url + "&state=#{self.class.encode_state(connection)}"
  end
end
