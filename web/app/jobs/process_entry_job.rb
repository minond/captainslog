class ProcessEntryJob < ApplicationJob
  queue_as :default

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

  def processor=(processor)
    @processor = processor
  end
end
