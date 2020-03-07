class ProcessEntryJob < ApplicationJob
  queue_as :default

  # @param [Entry] entry
  # @param [Processor] processor
  def perform(entry, processor = Processor::Runner)
    entry.process(processor)
  end
end
