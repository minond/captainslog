class ApplicationController < ActionController::Base
private

  # Helper method for rendering a view with local variables.
  #
  # @example
  #   locals
  #   locals :myview
  #   locals :myview, :foo => foo, :bar => bar
  #   locals :foo => foo, :bar => bar
  #
  # @param [Array<Any>] view
  # @param [Hash<Any, Any>] defs
  def locals(*view, **defs)
    render view.first, :locals => defs
  end
end
