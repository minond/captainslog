class Entry < ApplicationRecord
  belongs_to :book
  belongs_to :collection

  after_initialize :constructor
  before_save :process

  def text
    processed_text || original_text
  end

private

  def constructor
    self.data ||= {}
  end

  def process
    Processor.process(self)
  end
end
