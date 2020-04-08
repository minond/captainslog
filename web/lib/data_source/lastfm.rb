class DataSource::Lastfm < DataSource::Client
  DATA_PULL_BACKFILL_PERIOD_START = 2.years
  DATA_PULL_BACKFILL_PERIOD_END = 1.day
  DATA_PULL_STANDARD_PERIOD_START = 2.days
  DATA_PULL_STANDARD_PERIOD_END = 1.day

  # @param [Hash] options
  def initialize(options = {})
    client(options)
    @user = options.with_indifferent_access[:user]
  end

  # Path to page where user can start the authentication process for this data source.
  #
  # @param [Connection, nil] connection
  # @return [String]
  def auth_url(connection = nil)
    state = "?state=#{self.class.encode_state(connection)}"
    callback = URI.encode_www_form_component(config[:redirect_uri] + state)
    "#{base_auth_url}&cb=#{callback}"
  end

  # @return [String]
  def base_auth_url
    "http://www.last.fm/api/auth/?api_key=#{config[:api_key]}"
  end

  # @param [String] code
  def code=(code)
    session = client.auth.get_session(:token => code).with_indifferent_access
    self.user = session[:name]
  end

  # @return [Hash]
  def credential_options
    {
      :user => user
    }
  end

private

  attr_accessor :user

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<ProtoEntry>]
  def data_pull(**args)
    song_series(args)
  end

  # # @param [Date] start_date
  # # @param [Date] end_date
  # # @return [Array<HeartRate>]
  def song_series(**args)
    process_songs(load_songs(args))
  end

  # # @param [Date] start_date
  # # @param [Date] end_date
  # # @return [Array<Hash>]
  def load_songs(start_date: Date.today, end_date: start_date)
    map_over_date_range(start_date, end_date, 7.days) do |sub_start_date, sub_end_date|
      take_while_with_index do |i|
        client.user.get_recent_tracks(:user => user,
                                      :from => sub_start_date.to_i,
                                      :to => sub_end_date.to_i,
                                      :limit => 200,
                                      :page => i + 1)
      end
    end
  end

  # @param [Array<Hash>] results
  # @return [Array<Song>]
  def process_songs(results)
    results.flatten
           .filter { |result| Song.valid?(result) }
           .map { |result| Song.from_result(result) }
  end

  # TODO: Move this to a new home
  #
  # Takes while results of yielding are not nil. Passing a counter each time
  # the block is executed. Returns array containing every result of yielding,
  # excluding the last `nil` value.
  #
  # @yieldparam [Integer] i
  # @yieldreturn [Object]
  # @return [Array<Object>]
  def take_while_with_index
    i = 0
    buff = []

    loop do
      res = yield i
      break unless res.present?

      buff << res
      i += 1
    end

    buff
  end

  # TODO: Move this to a new home
  #
  # Helper method for iterating over date ranges with a step.
  #
  # @param [Date] start_date
  # @param [Date] end_date
  # @param [ActiveSupport::Duration] step
  # @yieldparam [Date] sub_start_date
  # @yieldparam [Date] sub_end_date
  # @yieldreturn [Object]
  # @return [Array<Object>]
  def map_over_date_range(start_date, end_date, step)
    results = []

    (start_date.to_datetime.to_i..end_date.to_datetime.to_i).step(step).each do |sub_start_timestamp|
      sub_start_date = Time.at(sub_start_timestamp)
      sub_end_date = sub_start_date + step
      sub_end_date = end_date.to_datetime if sub_end_date > end_date
      results += yield(sub_start_date, sub_end_date)
    end

    results
  end

  # @param [Hash] options
  # @return [::Lastfm]
  def client(_options = {})
    @client ||= ::Lastfm.new(config[:api_key], config[:api_secret])
  end

  # @return [Hash]
  def config
    @config ||= ::Rails.application.config.lastfm.with_indifferent_access
  end
end
