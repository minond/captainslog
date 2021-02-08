class Form < ViewComponent
  props :resource => ApplicationRecord,
        :url => String,
        :show_actions => MaybeBoolean

  def render
    form_for(resource, :url => url) do |f|
      html [children(f), actions]
    end
  end

  def actions
    show_actions ? Form::Actions.render(:submit => true) : ""
  end
end
