module Source::Client::TokenAuthenticated
  extend extend ActiveSupport::Concern

  class_methods do
    # @param [Symbol] name
    def callback_param(name)
      @callback_param_name = name
    end

    # @return [Symbol]
    def callback_param_name
      @callback_param_name || :callback
    end
  end

  # Auth token setter. Each client may handle this as needed.
  #
  # @param [String] token
  def token=(_token)
    raise NotImplementedError, "#token= is not implemented"
  end

  # Path to page where user can start the authentication process for this
  # source.
  #
  # @param [Connection, nil] connection
  # @return [String]
  def auth_url(connection = nil)
    state = "?state=#{self.class.encode_state(connection)}"
    callback = URI.encode_www_form_component(config[:redirect_uri] + state)

    uri = URI.parse(base_auth_url)
    uri.query ||= ""
    uri.query << "&#{self.class.callback_param_name}=#{callback}"
    uri.to_s
  end
end
