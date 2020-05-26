class JobShowComponent < Component
  props :job => Job

  def render
    ContentComponent.render [content, javascript]
  end

  def content
    <<-HTML
      <div data-job-details="#{job.id}">
        #{JobDetailsComponent.render(:job => job)}
        #{JobLogsComponent.render(:job => job)}
      </div>
    HTML
  end

  def javascript
    <<-HTML
      <script src="/assets/job.js"></script>
    HTML
  end
end
