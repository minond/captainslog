module Processor
  # @param [Entry] entry
  # @return [Entry]
  def self.process(entry)
    entry.data = entry.data.merge(standard_fields(entry))
    entry
  end

  # @param [Entry] entry
  # @return [Hash]
  def self.standard_fields(entry)
    {
      :_processed => true,
      :_processed_at => Time.now.utc.to_i,
      :_created_at => entry.created_at.to_i,
      :_updated_at => entry.updated_at.to_i
    }
  end
end
