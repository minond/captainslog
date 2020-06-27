class Job::Logs < ViewComponent
  props :job => Job

  def render
    <<-HTML
      <pre class="bg-near-white pa3 mt4 pre job-logs" data-job-details-logs>#{logs_string}</pre>
    HTML
  end

  def logs_string
    job.logs || t(:no_logs)
  end
end
