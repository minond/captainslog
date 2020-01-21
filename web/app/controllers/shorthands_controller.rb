class ShorthandsController < ApplicationController
  before_action :require_login

  def show
    locals :shorthand => current_shorthand
  end

private

  # Find and return the current "active" shorthand. This is scopes to the
  # user's shorthands.
  #
  # @return [Shorthand]
  def current_shorthand
    @current_shorthand ||= Shorthand.find_by!(:user => current_user,
                                              :id => params[:id])
  end
end
