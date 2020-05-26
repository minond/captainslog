class JobDetailsComponent < Component
  props :job => Job

  def render
    <<-HTML
      <table class="f6 w-50-l">
        <tbody class="lh-copy">
          <tr>
            <td class="pv2 ph3 bb b--black-10 nowrap w2 br b tr">#{t(:status)}</td>
            <td class="pv2 ph3 bb b--black-10 nowrap" data-job-details-status>#{job.presenter.status}</td>
          </tr>
          <tr>
            <td class="pv2 ph3 bb b--black-10 nowrap w2 br b tr">#{t(:kind)}</td>
            <td class="pv2 ph3 bb b--black-10 nowrap" data-job-details-kind>#{job.presenter.kind}</td>
          </tr>
          <tr>
            <td class="pv2 ph3 bb b--black-10 nowrap w2 br b tr">#{t(:message)}</td>
            <td class="pv2 ph3 bb b--black-10 mw7" data-job-details-message>#{job.message}</td>
          </tr>
          <tr>
            <td class="pv2 ph3 bb b--black-10 nowrap w2 br b tr">#{t(:run_time)}</td>
            <td class="pv2 ph3 bb b--black-10 nowrap" data-job-details-run_time>#{job.presenter.run_time}</td>
          </tr>
          <tr>
            <td class="pv2 ph3 bb b--black-10 nowrap w2 br b tr">#{t(:created_at)}</td>
            <td class="pv2 ph3 bb b--black-10 nowrap" data-job-details-created_at>#{job.created_at}</td>
          </tr>
          <tr>
            <td class="pv2 ph3 bb b--black-10 nowrap w2 br b tr">#{t(:started_at)}</td>
            <td class="pv2 ph3 bb b--black-10 nowrap" data-job-details-started_at>#{job.started_at}</td>
          </tr>
          <tr>
            <td class="pv2 ph3 bb b--black-10 nowrap w2 br b tr">#{t(:stopped_at)}</td>
            <td class="pv2 ph3 bb b--black-10 nowrap" data-job-details-stopped_at>#{job.stopped_at}</td>
          </tr>
        </tbody>
      </table>
    HTML
  end
end
