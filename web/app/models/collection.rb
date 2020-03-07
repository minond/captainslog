class Collection < ApplicationRecord
  belongs_to :book
  has_many :entries, :dependent => :destroy

  validates :book, :presence => true

  default_scope { order(:datetime => :desc) }
  scope :by_book_id, ->(id) { where(:book_id => id) }
  scope :datetime_between, ->(start_time, end_time) { where("datetime between ? and ?", start_time, end_time) }
end
