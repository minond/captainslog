class Entry < ApplicationRecord
  belongs_to :book
  belongs_to :collection

  after_initialize :constructor
  before_save :set_default_data

  def text
    processed_text || original_text
  end

private

  def constructor
    self.data ||= {}
  end

  def set_default_data
    self.data[:created_at] = Time.now.utc.to_i
  end
end
