class Entry < ApplicationRecord
  belongs_to :book
  belongs_to :collection

  after_initialize :constructor

  def text
    processed_text || original_text
  end

private

  def constructor
    self.data ||= {}
    self.data[:created_at] = Time.now.utc.to_i
  end
end
