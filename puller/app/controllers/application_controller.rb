class ApplicationController < ActionController::Base
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

  # Sets required headers to prevent response from being cached.
  def set_no_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"
  end
end
