class DataSource::OauthClient < DataSource::Client
  # Oauth code setter. Setting the code will trigger the Fitbit API client to
  # load an oauth token which it will continue to use in subseqent API calls.
  #
  # @param [String] code
  def code=(_code)
    raise NotImplementedError.new, "#code= is not implemented"
  end
end
