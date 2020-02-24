class OauthController < ApplicationController
  # === URL
  #   GET /oauth/fitbit
  #
  # === Sample request
  #   /oauth/fitbit?code=3j4k3lj4k3l2j32#_=_
  #
  def fitbit
    save_credentials(:fitbit)
    redirect_to "/user#fitbit"
  end

private

  # @return [String]
  def code
    params[:code]
  end

  # @param [Symbol] data_source
  def save_credentials(data_source)
    Credential.create_with_options(current_user, serialize_token(data_source))
  end

  # @param [Symbol] data_source
  def serialize_token(data_source)
    puller = Puller::Client.for_data_source(data_source).new
    puller.code = code
    puller.serialize_token
  end
end
