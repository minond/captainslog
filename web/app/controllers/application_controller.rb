class ApplicationController < ActionController::Base
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

  # This method ensures that `requested_time` matche the user's local time.
  # Wrap a controller's actions in this method to ensure that the correct
  # timezone is applied as the request is processed.
  #
  # @example
  #   around_action :use_timezone, :if => :current_user
  #
  # @return [Block] &block
  def use_timezone(&block)
    Time.use_zone(current_user.timezone, &block)
  end

  # The requsted time represents the time that a user is requesting entries be
  # loaded for or entries to be added under.
  #
  # @return [Time]
  def requested_time
    val = params[:requested_time]
    val.present? ? Time.at(val.to_i) : Time.current
  end
end
