module Processor
  # @param [Entry] entry
  # @return [Entry]
  def self.process(entry)
    entry.data[:created_at] = Time.now.utc.to_i
    entry
  end
end
