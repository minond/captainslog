class Service::Fitbit < Service::Client
  include Source
  include OauthAuthenticated

  config_from :fitbit

  pulls_in :heart_rate, :steps, :weight

  backfill_range 2.years..1.day
  standard_range 2.days..1.day

  # @return [String]
  def base_auth_url
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

private

  attr_reader :user_id

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<HeartRate>]
  def pull_heart_rate(start_date:, end_date:)
    client.heart_rate_time_series(:start_date => start_date, :end_date => end_date)
          .filter { |result| HeartRate.valid?(result) }
          .each { |result| yield HeartRate.from_result(result) }
  end

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<Steps>]
  def pull_steps(start_date:, end_date:)
    client.activity_time_series("tracker/steps", :start_date => start_date, :end_date => end_date)
          .filter { |result| Steps.valid?(result) }
          .each { |result| yield Steps.from_result(result) }
  end

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<Weight>]
  def pull_weight(start_date:, end_date:)
    # The weight API can only retrieve a maximum of 31 days at a time.
    results = map_over_date_range(start_date, end_date, 30.days) do |sub_start_date, sub_end_date|
      client.weight_log_period(sub_start_date, sub_end_date)
    end

    results.filter { |result| Weight.valid?(result) }
           .each { |result| yield Weight.from_result(result) }
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
end
