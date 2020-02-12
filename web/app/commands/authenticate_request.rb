class AuthenticateRequest
  prepend SimpleCommand

  # @param [Hash] headers
  def initialize(headers)
    @headers = headers
  end

  # @return [User, nil]
  def call
    user || errors.add(:token, "invalid token")
  end

private

  attr_reader :headers

  # @return [User, nil]
  def user
    User.find(user_id) if auth_token && user_id
  end

  # @return [Integer]
  def user_id
    token[:user_id]
  end

  # @return [Hash]
  def token
    @token ||= JWT.decode_application_token(auth_token) || {}
  end

  # @return [String, nil]
  def auth_token
    return auth_header.split(" ").last if auth_header.present?

    errors.add(:token, "missing token")
    nil
  end

  # @return [String, nil]
  def auth_header
    @auth_header ||= headers["Authorization"]
  end
end
