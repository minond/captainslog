class ConnectionRowComponent < Component
  props :connection => Connection

  def render
    <<-HTML
      <tr data-connection-id="#{connection.id}">
        <td class="nowrap pv0 pl0 bb b--black-10 service service-#{connection.service}"></td>
        <td class="nowrap pv0 pl0 bb b--black-10 dn dtc-ns">#{history}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{resources.join}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{connection.jobs.count}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{connection.last_updated_at}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{schedule_pull_link}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{authenticate_link}</td>
        <td class="nowrap pv3 pr3 bb b--black-10">#{delete_link}</td>
      </tr>
    HTML
  end

  def history
    ConnectionJobHistoryComponent.render(:connection => connection)
  end

  def resources
    connection.available_resources.map do |resource|
      PillBoxComponent.render(:label => resource.label)
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
end