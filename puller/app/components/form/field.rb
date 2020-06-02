class Form::Field < Component
  props :form => ActionView::Helpers::FormBuilder,
        :name => Symbol,
        :type => Symbol,
        :autofocus => MaybeBoolean

  def render
    [label, field, error]
  end

  def label
    form.label name, t(name), :class => "f6 lh-copy db"
  end

  def field
    case type
    when :email
      form.email_field name, attributes
    when :password
      form.password_field name, attributes
    else
      form.text_field name, attributes
    end
  end

  def attributes
    {
      :autofocus => autofocus,
      :class => class_string,
    }
  end

  def class_string
    "input-reset ba b--black-20 pa2 mb2 db w-100"
  end

  def error
    if form.object.errors.full_messages_for(name).any?
      <<-HTML
        <span class="f6 dark-red i">
          #{error_string}
        </span>
      HTML
    else
      ""
    end
  end

  def error_string
    form.object.errors.full_messages_for(name).join(", ")
  end
end
