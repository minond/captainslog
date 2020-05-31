class FormActionsComponent < Component
  props :submit => MaybeBoolean

  def render
    <<-HTML
      <div class="mt4">
        #{submit ? FormSubmitComponent.render : ""}
        #{block_given? ? yield : ""}
      </div>
    HTML
  end
end
