class Api::V1::TokenController < ApiController
  skip_before_action :authenticate_request

  # === URL
  #   POST /api/v1/token
  #
  # == Request fields
  #   [String] email
  #   [String] password
  #
  # == Sample request
  #   /api/v1/token?email=...&password=...
  #
  def create
    json authentication_response, :status => authentication_response_status
  end

private

  param_reader :email
  param_reader :password

  # Results from authentication request. Includes a "token" key if successful,
  # or an "error" key on failure.
  #
  # @return [Hash]
  def authentication_response
    if authenticate_user.success?
      { :token => authenticate_user.result }
    else
      { :error => :unauthorized }
    end
  end

  # HTTP status header label representing result of authentication request.
  #
  # @return [Symbol]
  def authentication_response_status
    authenticate_user.success? ? :ok : :unauthorized
  end

  # @return [AuthenticateUser]
  def authenticate_user
    @authenticate_user ||= AuthenticateUser.call(email, password)
  end
end
