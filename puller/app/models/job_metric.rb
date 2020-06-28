class JobMetric < ApplicationRecord
  belongs_to :user
  belongs_to :connection
  belongs_to :job

  enum :status => %i[initiated running errored done]

  validates :connection, :job, :user, :job_status, :run_time, :presence => true

  after_initialize :constructor

private

  def constructor
    self.user ||= connection.user
    self.job_status ||= job.status
  end
end
