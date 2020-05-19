class Users::SessionsController < Devise::SessionsController
  # POST /users/sign_in
  def create
    super do |user|
      if callback?
        respond_with user, :location => callback_url(user)
        return
      end
    end
  end

private

  # @return [Boolean]
  def callback?
    params[:callback].present?
  end

  # @param [User]
  # @return [String]
  def callback_url(user)
    url = URI.parse(params[:callback])
    url.query ||= ""
    url.query << "&token=#{user.jwt}"
    url.to_s
  end
end
