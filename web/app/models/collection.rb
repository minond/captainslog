class Collection < ApplicationRecord
  belongs_to :book

  after_initialize :constructor

  scope :by_book_id, lambda { |id| where(:book_id => id) }
  scope :created_between, lambda { |start_time, end_time| where("created_at between ? and ?", start_time, end_time) }

private

  def constructor
    self.open ||= false
  end
end
