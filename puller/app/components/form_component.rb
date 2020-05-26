class FormComponent < Component
  props :resource => Object,
        :url => String

  def render
    form_for(resource, :url => url) { |f| children(f) }
  end
end
