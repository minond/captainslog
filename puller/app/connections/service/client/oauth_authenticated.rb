module Service::Client::OauthAuthenticated
  extend extend ActiveSupport::Concern

  # Oauth code setter. Each client may handle this as needed.
  #
  # @param [String] code
  def code=(_code)
    raise NotImplementedError, "#code= is not implemented"
  end

  # Path to page where user can start the authentication process for this
  # service.
  #
  # @param [Connection, nil] connection
  # @return [String]
  def auth_url(connection = nil)
    base_auth_url + "&state=#{Service.encode_state(connection)}"
  end
end
