class Job < ApplicationRecord
  belongs_to :user
  belongs_to :connection

  validates :connection, :status, :kind, :user, :presence => true

  enum :status => %i[initiated running errored done]

  after_initialize :constructor
  after_create :schedule_processing

  # @return [String]
  def humanized_run_time
    return "--:--:--" if run_time.nil?

    Time.at(run_time).utc.strftime("%H:%M:%S")
  end

  # @return [String]
  def humanized_kind
    case kind.to_sym
    when :pull
      "Pull for #{connection.source.humanize}"
    when :backfill
      "Backfill for #{connection.source.humanize}"
    else
      kind.humanize
    end
  end

private

  def constructor
    self.status ||= :initiated
  end

  def schedule_processing
    ProcessJobJob.perform_later(id)
  end

  # @return [Float, nil]
  def run_time
    return nil if initiated? || started_at.nil?
    return DateTime.current - started_at.to_i if running?

    stopped_at - started_at
  end
end
