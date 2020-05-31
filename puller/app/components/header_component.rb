class HeaderComponent < Component
  props :key => Symbol
        :args => Object

  def render
    <<-HTML
      <div class="f3 baskerville mb3">
        #{t(key, **(args || {}))}
      </div>
    HTML
  end
end
