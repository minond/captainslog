class Job::Show < ViewComponent
  props :job => Job

  def render
    ViewContainer.render [details, javascript]
  end

  def details
    Job::Details.render(:job => job)
  end

  def javascript
    <<-HTML
      <script>
        streamModelUpdates("JobChannel", { job_id: #{job.id} })
      </script>
    HTML
  end
end
