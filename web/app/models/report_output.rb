class ReportOutput < ApplicationRecord
  belongs_to :report
  belongs_to :user

  after_initialize :constructor

  validates :label, :kind, :report, :user, :presence => true
  validates :label, :uniqueness => { :scope => :report }

  enum :kind => %i[table value chart], :_prefix => true

private

  def constructor
    self.user ||= report&.user
  end
end
