class DataSource::Lastfm < DataSource::Client
  include Iter

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
