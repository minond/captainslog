class Connection::Row < ViewComponent
  props :connection => Connection

  def render
    <<-HTML
      <tr data-model="connection" data-component="row" data-id="#{connection.id}">
        <td class="nowrap pv0 pl0 bb b--black-10 service service-#{connection.service}"></td>
        <td class="nowrap pv0 pl0 bb b--black-10 dn dtc-ns" id="#{id}">#{draw_metrics_graph_code}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{resources.join}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{connection.last_updated_at}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{schedule_pull_link}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{schedule_backfill_link}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{authenticate_link}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{delete_link}</td>
      </tr>
    HTML
  end

  def id
    @id ||= "id#{SecureRandom.alphanumeric}"
  end

  def draw_metrics_graph_code
    <<-HTML
      <script>drawLineGraph("##{id}", #{metrics.to_json})</script>
    HTML
  end

  def metrics
    connection.recent_metrics(100).map(&:run_time)
  end

  def resources
    connection.vertices.map do |vertex|
      link_to PillBox.render(:label => vertex.resource.label),
              edit_connection_vertex_path(connection, vertex),
              :class => "link"
    end
  end

  def authenticate_link
    link_to t(:authenticate),
            authenticate_connection_path(connection),
            :class => "link blue"
  end

  def delete_link
    link_to t(:delete),
            connection_path(connection),
            :method => :delete,
            :data => { :confirm => t(:are_you_sure) },
            :class => "link blue"
  end

  def schedule_pull_link
    if connection.source?
      link_to t(:schedule_pull), schedule_pull_connection_path(connection), :class => "link blue", :remote => true
    else
      ""
    end
  end

  def schedule_backfill_link
    if connection.source?
      link_to t(:schedule_backfill), schedule_backfill_connection_path(connection), :class => "link blue", :remote => true
    else
      ""
    end
  end
end
