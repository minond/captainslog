class ProcessEntryJob < ApplicationJob
  queue_as :default

  # @param [Entry] entry
  # @param [Processor] processor, defaults to `Processor::Runner`
  def perform(entry, processor = Processor::Runner)
    text, data = processor.process(entry)
    entry.text = text
    entry.data = data
    entry.save
  end
end
