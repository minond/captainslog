module Source::Client::Token
  extend extend ActiveSupport::Concern

  # Auth token setter. Each client may handle this as needed.
  #
  # @param [String] token
  def token=(_token)
    raise NotImplementedError, "#token= is not implemented"
  end
end
