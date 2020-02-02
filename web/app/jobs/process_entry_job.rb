class ProcessEntryJob < ApplicationJob
  queue_as :default

  # @param [Entry] entry
  # @param [Processor] processor
  def perform(entry, processor = Processor::Runner)
    text, data = processor.run(entry)
    entry.update_from_processor(text, data)
  end
end
