class JobPresenter
  def initialize(job)
    @job = job
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  #
  # Returns a human-friendly representation of the job that is ready to be
  # presented to users.
  #
  # @return [Hash]
  def details
    {
      :id => job.id,
      :status => status,
      :kind => kind,
      :message => job.message,
      :run_time => run_time,
      :created_at => job.created_at.to_s,
      :started_at => job.started_at.to_s,
      :stopped_at => job.stopped_at.to_s,
      :logs => job.logs,
    }
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # @return [String]
  def run_time
    return "--:--:--" if job.run_time.nil?

    Time.at(job.run_time).utc.strftime("%H:%M:%S")
  end

  # @return [String]
  def status
    job.status.humanize
  end

  # @return [String]
  def kind
    case job.kind.to_sym
    when :pull
      "Pull for #{job.connection.source.humanize}"
    when :backfill
      "Backfill for #{job.connection.source.humanize}"
    else
      job.kind.humanize
    end
  end

private

  attr_reader :job
end
