module CallbackRedirect
  extend extend ActiveSupport::Concern

  def callback_redirect(user: current_user)
    redirect_to callback_redirect_url(:user => user)
  end

  def callback_redirect_url(user: current_user, url: callback)
    uri = URI.parse(url)
    uri.query ||= ""
    uri.query << "&token=#{user.jwt}"
    uri.to_s
  end

  def callback
    params[:callback]
  end
end
