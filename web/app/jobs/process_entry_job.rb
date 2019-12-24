class ProcessEntryJob < ApplicationJob
  queue_as :default

  # @param [Entry] entry
  def perform(entry)
    Processor.process(entry).save
  end
end
