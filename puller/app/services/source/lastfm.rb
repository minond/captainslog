class Source::Lastfm < Source::Client
  include Source::Client::Input
  include Source::Client::TokenAuthenticated

  callback_param :cb
  config_from :lastfm

  pulls_in :songs

  backfill_range 2.years..1.day
  standard_range 2.days..1.day

  LIMIT = 200

  # @param [Hash] options
  def initialize(options = {})
    super
    @user = options.with_indifferent_access[:user]
  end

  # @return [String]
  def base_auth_url
    "http://www.last.fm/api/auth/?api_key=#{config[:api_key]}"
  end

  # @param [String] token
  def token=(token)
    session = client.auth.get_session(:token => token).with_indifferent_access
    self.user = session[:name]
  end

  # @return [Hash]
  def credential_options
    { :user => user }
  end

private

  attr_accessor :user

  # # @param [Date] start_date
  # # @param [Date] end_date
  # # @return [Array<Hash>]
  def pull_songs(start_date:, end_date:, &block)
    map_over_date_range(start_date, end_date, 7.days) do |sub_start_date, sub_end_date|
      take_while_with_index do |i|
        songs = client.user.get_recent_tracks(song_page_params(i + 1, sub_start_date, sub_end_date))
        processed = process_songs(songs, &block)
        processed.empty? || processed.size < LIMIT ? nil : true
      end
    end
  end

  # @param [Integer] page
  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Hash]
  def song_page_params(page, start_date, end_date)
    {
      :user => user,
      :from => start_date.to_i,
      :to => end_date.to_i,
      :limit => LIMIT,
      :page => page
    }
  end

  # @param [Array<Hash>, Hash] results
  # @return [Array<Song>]
  def process_songs(results)
    Array.wrap(results)
         .flatten
         .filter { |result| Song.valid?(result) }
         .each { |result| yield Song.from_result(result) }
  end

  # @param [Hash] options
  # @return [::Lastfm]
  def client(_options = {})
    @client ||= ::Lastfm.new(config[:api_key], config[:api_secret])
  end
end
