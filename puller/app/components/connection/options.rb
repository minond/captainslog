class Connection::Options < ViewComponent
  class Option < ViewComponent
    props :service => Symbol,
          :ext => Symbol

    def render
      <<-HTML
        <a class="link black pointer fl mw6 pa2 border-box" href="/connection/initiate/#{service}">
          <input class="service-radio dn" type="radio" name="connection[service]" value="#{service}" />
          <div class="service-box pa4 ba b--black-10 tc">
            <img src="#{"/assets/#{service}-logo.#{ext}"}" class="h3" />
            <p class="lh-copy">#{t(:"#{service}_connection_description")}</p>
          </div>
        </a>
      HTML
    end
  end

  def render
    <<-HTML
      <div class="cf mb4">
        #{options.join}
      </div>
    HTML
  end

  def options
    [:captainslog, :fitbit, %i[lastfm svg]].map do |(service, ext)|
      Option.render(:service => service, :ext => ext || :png)
    end
  end
end
