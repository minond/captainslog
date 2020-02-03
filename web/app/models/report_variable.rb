class ReportVariable < ApplicationRecord
  belongs_to :report
  belongs_to :user

  after_initialize :constructor

  validates :label, :report, :user, :presence => true

private

  def constructor
    self.user ||= report&.user
  end
end
