class Form::Actions < Component
  props :submit => MaybeBoolean

  def render
    <<-HTML
      <div class="mt4">
        #{submit ? Form::Submit.render : ""}
        #{block_given? ? yield : ""}
      </div>
    HTML
  end
end
