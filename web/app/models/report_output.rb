class ReportOutput < ApplicationRecord
  belongs_to :report

  validates :label, :kind, :report, :presence => true
  validates :label, :uniqueness => { :scope => :report }

  enum :kind => %i[table value chart], :_prefix => true

  default_scope { order(:order => :asc) }
end
