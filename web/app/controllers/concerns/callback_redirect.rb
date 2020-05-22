module CallbackRedirect
  extend extend ActiveSupport::Concern

  def callback_redirect(user: current_user)
    redirect_to callback_redirect_url(:user => user)
  end

  def callback_redirect_url(user: current_user, url: callback)
    url = URI.parse(callback)
    url.query ||= ""
    url.query << "&token=#{user.jwt}"
    url.to_s
  end

  def callback
    params[:callback]
  end
end
