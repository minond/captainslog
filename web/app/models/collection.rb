class Collection < ApplicationRecord
  belongs_to :book
  has_many :entries

  after_initialize :constructor

  scope :by_book_id, ->(id) { where(:book_id => id) }
  scope :datetime_between, ->(start_time, end_time) { where("datetime between ? and ?", start_time, end_time) }

private

  def constructor
    self.datetime ||= self.datetime.utc
  end
end
