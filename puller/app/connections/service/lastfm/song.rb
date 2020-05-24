class Service::Lastfm::Song < Service::Record
  # @param [Hash] result
  # @return [Song]
  def self.from_result(result)
    song = result["name"]
    album = result.dig("album", "content")
    artist = result.dig("artist", "content")

    new("Song: #{song}\nAlbum: #{album}\nArtist: #{artist}",
        DateTime.parse(result["date"]["content"]))
  end

  # @param [Hash] result
  # @return [Boolean]
  def self.valid?(result)
    result.dig("name").present? &&
      result.dig("artist", "content").present? &&
      result.dig("date", "content").present?
  end

  # @return [String]
  def digest
    Base64.encode64("lastfm-song-#{date}")
  end
end
