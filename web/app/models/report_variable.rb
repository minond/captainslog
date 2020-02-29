class ReportVariable < ApplicationRecord
  belongs_to :report

  validates :label, :report, :presence => true
end
