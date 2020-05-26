class FormSubmitComponent < Component
  def render
    <<-HTML
      <input type="submit" value="#{t(:submit)}" class="f6 link bn pa0 input-reset pointer blue" />
    HTML
  end
end
