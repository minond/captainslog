class Select < Component
  props :name => MaybeString,
        :placeholder => MaybeBoolean,
        :autofocus => MaybeBoolean,
        :disabled => MaybeBoolean,
        :submits => MaybeBoolean

  module Helper
    def select(options, **attrs)
      Select.render(attrs) do
        options.map do |(value, text)|
          Option.render(:value => value.to_s,
                        :text => text)
        end
      end
    end
  end

  class Option < Component
    props :text => String,
          :value => MaybeString,
          :selected => MaybeBoolean,
          :disabled => MaybeBoolean

    def render
      <<-HTML
        <option
          value="#{value || text}"
          #{selected ? "selected" : ""}
          #{disabled ? "disabled" : ""}
        >
          #{text}
        </option>
      HTML
    end
  end

  def render
    <<-HTML
      <select
        class="f6 w5"
        name="#{name}"
        #{autofocus ? "autofocus" : ""}
        #{disabled ? "disabled" : ""}
        #{submits ? "onchange='this.form.submit()'" : ""}
      >
        #{placeholder_option}
        #{children}
      </select>
    HTML
  end

  def placeholder_option
    return "" unless placeholder

    Option.render(:text => t(:select_option),
                  :disabled => true,
                  :selected => true)
  end
end
