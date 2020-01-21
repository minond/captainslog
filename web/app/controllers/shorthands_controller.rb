class ShorthandsController < ApplicationController
  before_action :require_login

  # === URL
  #   GET /shorthands/:id
  #
  # === Sample request
  #   /shorthands/1
  #
  def show
    locals :shorthand => current_shorthand
  end

  # === URL
  #   PATCH /shorthands/:id
  #
  # === Request fields
  #   [Integer] shorthand[priority] - priority number
  #   [String] shorthand[expansion] - the shorthand expansion
  #   [String] shorthand[match] - the shorthand match
  #   [String] shorthand[text] - the shorthand text
  #
  # === Sample request
  #   /shorthands/1?expansion=ok
  #
  def update
    ok = update_shorthand
    notify(ok, :successful_shorthand_update, :failure_in_shorthand_update)
    ok ? redirect_to(current_shorthand) : locals(:show, :shorthand => current_shorthand)
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

  # Update the shorthand and return true if there were not errors doing so.
  #
  # @return [Boolean]
  def update_shorthand
    current_shorthand.update(permitted_shorthand_params)
    current_shorthand.errors.empty?
  end

  # @return [ActionController::Parameters]
  def permitted_shorthand_params
    params.require(:shorthand)
          .permit(:priority, :expansion, :match, :text)
  end
end
