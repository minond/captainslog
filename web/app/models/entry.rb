class Entry < ApplicationRecord
  belongs_to :book
  belongs_to :collection

  def text
    processed_text || original_text
  end
end
