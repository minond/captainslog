class ProcessEntryJob < ApplicationJob
  queue_as :default

  # @param [Entry] entry
  # @param [Processor] processor, defaults to `Processor::Runner`
  def perform(entry, processor = Processor::Runner)
    text, data = processor.run(entry)
    entry.processed_text = text
    entry.processed_data = data
    entry.save
  end
end
