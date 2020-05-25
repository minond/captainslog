class AvailableConnectionsComponent < Component
  def render
    <<-HTML
      <div class="cf mb4">
        #{options.join}
      </div>
    HTML
  end

  def options
    [:captainslog, :fitbit, %i[lastfm svg]].map do |(service, ext)|
      AvailableConnectionOptionComponent.render(:service => service, :ext => ext || :png)
    end
  end
end
