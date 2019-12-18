class Collection < ApplicationRecord
  belongs_to :book
  has_many :entries

  scope :by_book_id, ->(id) { where(:book_id => id) }
  scope :created_between, ->(start_time, end_time) { where("created_at between ? and ?", start_time, end_time) }
end
