module EntryHelper
  # Generates JavaScript code that polls for entry updates. To prevent the
  # server from getting overloaded with polling requests it will only poll for
  # updates for the latest N entries, where N is controlled by the
  # `max_entries_to_poll` parameter.
  #
  # @param [Array<Entry>] entries
  # @param [Integer] max_entries_to_poll
  # @param [Integer] wait_time
  # @return [String]
  def self.entry_processing_polling_code(entries, max_entries_to_poll: 5, wait_time: 2000)
    ids = entries.reject(&:processed_data?).first(max_entries_to_poll).map(&:id)
    ids.empty? ? "" : "pollForEntryUpdates('#{entries.first.book.slug}', [#{ids.join(', ')}], #{wait_time})"
  end
end
