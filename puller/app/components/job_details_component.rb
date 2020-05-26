class JobDetailsComponent < Component
  props :job => Job

  # rubocop:disable Metrics/AbcSize
  def render
    table [
      row(:status, job.presenter.status),
      row(:kind, job.presenter.kind),
      row(:message, job.message),
      row(:run_time, job.presenter.run_time),
      row(:created_at, job.created_at),
      row(:started_at, job.started_at),
      row(:stopped_at, job.stopped_at),
    ]
  end
  # rubocop:enable Metrics/AbcSize

  def table(rows)
    <<-HTML
      <table class="f6 w-50-l">
        <tbody class="lh-copy">
          #{rows.join}
        </tbody>
      </table>
    HTML
  end

  def row(field, value)
    <<-HTML
      <tr>
        <td class="pv2 ph3 bb b--black-10 nowrap w2 br b tr">#{t(field)}</td>
        <td class="pv2 ph3 bb b--black-10 nowrap" data-job-details-#{field}>#{value}</td>
      </tr>
    HTML
  end
end
