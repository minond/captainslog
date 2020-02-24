class OauthController < ApplicationController
  # === URL
  #   GET /oauth/fitbit
  #
  # === Sample request
  #   /oauth/fitbit?code=3j4k3lj4k3l2j32#_=_
  #
  def fitbit
    render :json => { :ok => code }
  end

private

  def code
    params[:code]
  end
end
