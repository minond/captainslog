class ViewContainer < ViewComponent
  def render
    <<-HTML
      <div class="db w-100 pt4 pt5-ns pb5 pa2 ph5-l">
        #{children}
      </div>
    HTML
  end
end
