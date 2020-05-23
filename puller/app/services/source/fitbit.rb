class Source::Fitbit < Source::Client
  include Source::Input
  include Source::Oauth

  backfill_range 2.years..1.day
  standard_range 2.days..1.day

  traced :data_pull, :heart_rate_time_series, :steps_time_series,
         :weight_time_series

  # @param [Hash] options
  def initialize(options = {})
    client(options)
  end

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

  attr_accessor :user_id

  # @param [Date] start_date
  # @param [Date] end_date
  # @yieldparam [ProtoEntry]
  # @return [Array<ProtoEntry>]
  def data_pull(**args, &block)
    heart_rate_time_series(args, &block)
    steps_time_series(args, &block)
    weight_time_series(args, &block)
  end

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<HeartRate>]
  def heart_rate_time_series(start_date: Date.today, end_date: start_date)
    client.heart_rate_time_series(:start_date => start_date, :end_date => end_date)
          .filter { |result| HeartRate.valid?(result) }
          .each { |result| yield HeartRate.from_result(result) }
  end

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<Steps>]
  def steps_time_series(start_date: Date.today, end_date: start_date)
    client.activity_time_series("tracker/steps", :start_date => start_date, :end_date => end_date)
          .filter { |result| Steps.valid?(result) }
          .each { |result| yield Steps.from_result(result) }
  end

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<Weight>]
  def weight_time_series(start_date: Date.today, end_date: start_date)
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
