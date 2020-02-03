class ReportOutput < ApplicationRecord
  belongs_to :report
  belongs_to :user

  validates :label, :kind, :report, :user, :presence => true
  validates :label, :uniqueness => { :scope => :report }

  enum :kind => %i[table value chart], :_prefix => true
end
