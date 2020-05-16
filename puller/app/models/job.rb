class Job < ApplicationRecord
  include Presenter

  belongs_to :user
  belongs_to :connection

  validates :connection, :status, :kind, :user, :presence => true

  enum :status => %i[initiated running errored done]

  after_initialize :constructor
  after_create :schedule_processing
  after_save :broadcast_record

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

  def schedule_processing
    ProcessJobJob.perform_later(id)
  end

  def broadcast_record
    ActionCable.server.broadcast("jobs_for_user_#{user.id}", :job => self,
                                                             :connection => connection)
  end
end
