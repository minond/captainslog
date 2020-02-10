class Api::V1::AuthenticationController < ApiController
  def authenticate
    json authentication_response, :status => authentication_response_status
  end

private

  # Results from authentication request. Includes a "token" key if successful,
  # or an "error" key on failure.
  #
  # @return [Hash]
  def authentication_response
    authenticate_user.success? ?
      { :token => authenticate_user.result } :
      { :error => authenticate_user.errors }
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

  # @return [String]
  def email
    params[:email]
  end

  # @return [String]
  def password
    params[:password]
  end
end
