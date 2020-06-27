class Header < ViewComponent
  props :key => Symbol,
        :args => MaybeHash

  def render
    <<-HTML
      <div class="f3 baskerville mb3">
        #{t(key, **(args || {}))}
      </div>
    HTML
  end
end
