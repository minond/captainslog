class AuthenticateUser
  prepend SimpleCommand

  # @param [String] email, user's email
  # @param [String] password, user's password
  def initialize(email, password)
    @email = email
    @password = password
  end

  # @return [String, Nil]
  def call
    JWT.encode_application_token(:user_id => user.id) if user
  end

private

  attr_reader :email, :password

  # @return [User]
  def user
    @user ||=
      begin
        user = User.find_by_email(email)
        if user&.valid_password?(password)
          user
        else
          errors.add :user_authentication, "invalid credentials"
          nil
        end
      end
  end
end
