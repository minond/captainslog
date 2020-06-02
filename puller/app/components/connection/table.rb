class Connection::Table < Component
  props :connections => [Connection]

  def render
    <<-HTML
      <div class="overflow-auto">
        <table class="f6 w-100 collapse">
          <thead>
            <tr>
              <th class="nowrap fw6 bb b--black-10 tl pb3 ph3 w100px"></th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3 dn dtc-ns">#{t(:history)}</th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3">#{t(:resources)}</th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3 w4">#{t(:sync_count)}</th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3 w5">#{t(:last_updated_at)}</th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3 w1"></th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3 w1"></th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3 w1"></th>
            </tr>
          </thead>
          <tbody class="lh-copy" data-model="connection" data-component="rows">
            #{rows.join}
          </tbody>
        </table>
      </div>
    HTML
  end

  def rows
    connections.map do |connection|
      Connection::Row.render(:connection => connection)
    end
  end
end
