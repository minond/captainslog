class ApplicationController < ActionController::Base
  include Component::Rendering

  # Generates a getter method for a request parameter
  #
  # @example call
  #
  #   param_reader :code
  #
  #
  # @example result
  #
  #   def code
  #     params[:code]
  #   end
  #
  #
  # @param [Symbol] param
  def self.param_reader(param)
    define_method(param) do
      params[param]
    end
  end

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
