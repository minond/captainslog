class ProcessEntryJob < ApplicationJob
  queue_as :default

  attr_writer :processor

  # @param [Entry] entry
  def perform(entry)
    text, data = processor.process(entry)
    entry.text = text
    entry.data = data
    entry.save
  end

  def processor
    @processor || Processor
  end
end
