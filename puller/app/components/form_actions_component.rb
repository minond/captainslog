class FormActionsComponent < Component
  props :submit => [NilClass, TrueClass, FalseClass]

  def render
    <<-HTML
      <div class="mt4">
        #{submit ? FormSubmitComponent.render : ""}
        #{block_given? ? yield : ""}
      </div>
    HTML
  end
end
