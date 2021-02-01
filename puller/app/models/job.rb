class Job < ApplicationRecord
  include Broadcaster
  include Performer
  include Presenter

  performs ProcessJobJob

  belongs_to :user
  belongs_to :connection
  has_many :job_metrics, :dependent => :destroy

  validates :connection, :status, :kind, :user, :presence => true

  enum :status => %i[initiated running errored done]

  after_initialize :constructor
  after_create :perform_process_job_later
  after_save :broadcast_user_job
  after_save :broadcast_user_connection

  # @return [Float, nil]
  def run_time
    return nil if initiated? || started_at.nil?
    return DateTime.current.utc - started_at.to_i if running?

    stopped_at - started_at
  end

private

  def constructor
    self.status ||= :initiated
  end
end
