class Form::SectionLabel < ViewComponent
  props :key => Symbol

  def render
    <<-HTML
      <p class="lh-copy i f6 mt4">#{t(key)}</p>
    HTML
  end
end
