class Connection < ApplicationRecord
  belongs_to :user

  validates :source, :user, :presence => true
end
