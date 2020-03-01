class DataSource::Fitbit < DataSource::OauthClient
  frequency! :daily

  # @param [Hash] options
  def initialize(options = {})
    client(options)
  end

  # @return [String]
  def auth_url
    client.auth_url
  end

  # @param [String] code
  def code=(code)
    client.get_token(code)
    @user_id = client.token["user_id"]
  end

  # @return [Hash]
  def credential_options
    token = client.token
    {
      :user_id => user_id,
      :access_token => token.token,
      :refresh_token => token.refresh_token,
      :expires_at => token.expires_at,
    }
  end

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<ProtoEntry>]
  def pull(**args)
    heart_rate_time_series(args) + steps_time_series(args)
  end

private

  attr_accessor :user_id

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<HeartRate>]
  def heart_rate_time_series(start_date: Date.today, end_date: start_date)
    client.heart_rate_time_series(:start_date => start_date, :end_date => end_date)
          .filter { |result| HeartRate.valid?(result) }
          .map { |result| HeartRate.from_result(result) }
  end

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<Steps>]
  def steps_time_series(start_date: Date.today, end_date: start_date)
    client.activity_time_series("tracker/steps", :start_date => start_date, :end_date => end_date)
          .filter { |result| Steps.valid?(result) }
          .map { |result| Steps.from_result(result) }
  end

  # @param [Hash] options
  # @return [::FitbitAPI::Client]
  def client(options = {})
    @client ||= begin
                  conf = config(options)
                  @user_id = conf["user_id"]
                  ::FitbitAPI::Client.new(conf)
                end
  end

  # @param [Hash] options
  #
  # @option [String] user_id
  # @option [String] access_token
  # @option [String] refresh_token
  # @option [Integer] expires_at
  #
  # @return [Hash]
  def config(options = {})
    options.merge(::Rails.application.config.fitbit).with_indifferent_access
  end
end
