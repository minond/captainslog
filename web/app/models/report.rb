class Report < ApplicationRecord
  belongs_to :user
  has_many :report_output
  has_many :report_variable

  validates :label, :user, :presence => true
end
