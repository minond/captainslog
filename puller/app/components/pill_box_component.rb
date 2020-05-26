class PillBoxComponent < Component
  props :label => String

  def render
    <<-HTML
      <span class="f7 pv1 ph2 ba b--black-20 pointer">#{label}</span>
    HTML
  end
end
