class Welcome::Home < ViewComponent
  props :connections => [Connection],
        :jobs => [Job]

  def render
    ViewContainer.render do
      if connections.empty?
        zero_state
      else
        main_content
      end
    end
  end

  def zero_state
    <<-HTML
      <p class="pl2 lh-copy">#{t(:no_connections_create_one)}</p>
      #{Connection::Options.render}
    HTML
  end

  def main_content
    [connections_table, separator, jobs_table, javascript]
  end

  def connections_table
    Connection::Table.render(:connections => connections)
  end

  def jobs_table
    Job::Table.render(:jobs => jobs)
  end

  def separator
    <<-HTML
      <div class="pt4 pt5-ns"></div>
    HTML
  end

  def javascript
    <<-HTML
      <script>
        streamModelUpdates("JobChannel")
        streamModelUpdates("ConnectionChannel")
      </script>
    HTML
  end
end
