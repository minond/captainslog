class SectionComponent < Component
  def render
    <<-HTML
      <div class="measure-wide">
        #{children}
      </div>
    HTML
  end
end
