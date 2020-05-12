class Connection < ApplicationRecord
  belongs_to :user
  has_many :credentials, :dependent => :destroy

  validates :source, :user, :presence => true
end
