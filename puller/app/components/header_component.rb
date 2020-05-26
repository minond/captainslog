class HeaderComponent < Component
  props :key => Symbol

  def render
    <<-HTML
      <div class="f3 baskerville mb3">
        #{t(:settings)}
      </div>
    HTML
  end
end
