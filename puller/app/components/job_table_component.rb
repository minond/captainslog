class JobTableComponent < Component
  props :jobs => [Job]

  def render
    <<-HTML
      <div class="overflow-auto">
        <table class="f6 w-100 collapse">
          <thead>
            <tr>
              <th class="nowrap fw6 bb b--black-10 tl pb3 ph3 w100px"></th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3 w4">#{t(:kind)}</th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3">#{t(:message)}</th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3 w4">#{t(:run_time)}</th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3 w5">#{t(:created_at)}</th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3 w5">#{t(:started_at)}</th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3 w5">#{t(:stopped_at)}</th>
              <th class="nowrap fw6 bb b--black-10 tl pb3 pr3 w1"></th>
            </tr>
          </thead>
          <tbody class="lh-copy" data-jobs>
            #{rows.join}
          </tbody>
        </table>
      </div>
    HTML
  end

  def rows
    jobs.map do |job|
      JobRowComponent.render(:job => job)
    end
  end
end
