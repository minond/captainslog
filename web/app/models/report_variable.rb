class ReportVariable < ApplicationRecord
  belongs_to :report
  belongs_to :user

  validates :label, :report, :user, :presence => true
end
