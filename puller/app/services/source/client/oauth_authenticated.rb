module Source::Client::OauthAuthenticated
  extend extend ActiveSupport::Concern

  # Oauth code setter. Each client may handle this as needed.
  #
  # @param [String] code
  def code=(_code)
    raise NotImplementedError, "#code= is not implemented"
  end
end
