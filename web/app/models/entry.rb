class Entry < ApplicationRecord
  belongs_to :book
  belongs_to :collection

  after_initialize :constructor
  after_create :schedule_processing

  def text
    processed_text || original_text
  end

  def text=(text)
    @processed_text = text
  end

private

  def constructor
    self.data ||= {}
  end

  def schedule_processing
    ProcessEntryJob.perform_later self
  end
end
