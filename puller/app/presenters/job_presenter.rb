class JobPresenter
  def initialize(job)
    @job = job
  end

  # @return [String]
  def run_time
    return "--:--:--" if job.run_time.nil?

    Time.at(job.run_time).utc.strftime("%H:%M:%S")
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
