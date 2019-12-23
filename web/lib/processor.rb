module Processor
  # @param [Entry] entry
  def self.process(entry)
    entry.data[:created_at] = Time.now.utc.to_i
  end
end
