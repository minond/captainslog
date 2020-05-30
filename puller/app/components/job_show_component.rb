class JobShowComponent < Component
  props :job => Job

  def render
    ContentComponent.render [details, javascript]
  end

  def details
    JobDetailsComponent.render(:job => job)
  end

  def javascript
    <<-HTML
      <script>
        streamModelUpdates("JobChannel", { job_id: #{job.id} })
      </script>
    HTML
  end
end
