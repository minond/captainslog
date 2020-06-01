class FormComponent < Component
  props :resource => ApplicationRecord,
        :url => String,
        :show_actions => MaybeBoolean

  def render
    form_for(resource, :url => url) do |f|
      html [children(f), actions]
    end
  end

  def actions
    show_actions ? FormActionsComponent.render(:submit => true) : ""
  end
end
