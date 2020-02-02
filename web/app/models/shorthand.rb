class Shorthand < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :priority, :expansion, :book, :user, :presence => true
end
