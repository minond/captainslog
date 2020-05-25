class JobStatusComponent < Component
  props :id => Integer,
        :status => String

  def render
    <<-HTML
      <a href="#{job_path(id)}" class="link job-status-ball-#{status}"></a>
    HTML
  end
end
