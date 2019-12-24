module Processor
  # @param [Entry] entry
  # @return [Entry]
  def self.process(entry)
    entry.data[:_processed] = true
    entry.data[:_processed_at] = Time.now.utc.to_i
    entry.data[:_created_at] = entry.created_at.to_i
    entry.data[:_updated_at] = entry.updated_at.to_i
    entry
  end
end
