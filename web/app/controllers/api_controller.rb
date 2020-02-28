class ApiController < ActionController::API
  before_action :authenticate_request

  # Generates a getter method for a request parameter
  #
  # @example call
  #
  #   param_reader :code
  #
  #
  # @example result
  #
  #   def code
  #     params[:code]
  #   end
  #
  #
  # @param [Symbol] param
  def self.param_reader(param)
    define_method(param) do
      params[param]
    end
  end

private

  # JSON rendering helper method
  #
  # @param [Hash] response
  # @param [hash] options
  def json(response, options = {})
    render options.merge(:json => response)
  end

  # Ensure the request is authenticated. This will check the JWT token and load
  # the current user into memory.
  #
  # On failure to authenticated the request a 401 response is immediatelly
  # returned.
  def authenticate_request
    render :json => { :error => :unauthorized }, :status => :unauthorized unless current_user
  end

  # @return [User]
  def current_user
    @current_user ||= AuthenticateRequest.call(request.headers).result
  end
end
