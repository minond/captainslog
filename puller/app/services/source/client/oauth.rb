module Source::Client::Oauth
  extend extend ActiveSupport::Concern

  # Oauth code setter. Setting the code will trigger the Fitbit API client to
  # load an oauth token which it will continue to use in subseqent API calls.
  #
  # @param [String] code
  def code=(_code)
    raise NotImplementedError, "#code= is not implemented"
  end
end
