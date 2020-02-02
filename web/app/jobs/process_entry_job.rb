class ProcessEntryJob < ApplicationJob
  queue_as :default

  # @param [Entry] entry
  # @param [Processor] processor
  def perform(entry, processor = Processor::Runner)
    text, data = processor.run(entry)
    entry.update(:processed_text => text, :processed_data => data)
  end
end
