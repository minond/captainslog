class Entry < ApplicationRecord
  belongs_to :book
  belongs_to :collection
end
