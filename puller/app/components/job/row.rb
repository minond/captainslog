class Job::Row < ViewComponent
  props :job => Job

  # rubocop:disable Metrics/AbcSize
  def render
    <<-HTML
      <tr data-model="job" data-component="row" data-id="#{job.id}">
        <td class="nowrap pv3 ph3 bb b--black-10 tc">#{job_status}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{job.presenter.kind}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{job.message}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{job.presenter.run_time}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{job.created_at}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{job.started_at}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{job.stopped_at}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{details_link}</td>
      </tr>
    HTML
  end
  # rubocop:enable Metrics/AbcSize

  def job_status
    Job::Status.render(:id => job.id, :status => job.status)
  end

  def details_link
    link_to t(:view_details), job_path(job), :class => "link blue"
  end
end
