class Collection < ApplicationRecord
  belongs_to :book

  after_initialize :constructor

private

  def constructor
    self.open ||= false
  end
end
