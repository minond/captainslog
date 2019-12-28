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

  # This method ensures that `requested_time` matche the user's local time.
  # Wrap a controller's actions in this method to ensure that the correct
  # timezone is applied as the request is processed.
  #
  # @example
  #   around_action :user_timezone
  #
  # @return [Block] &block
  def user_timezone(&block)
    return yield unless current_user

    Time.use_zone(current_user.timezone, &block)
  end

  # Redirect request to the login page when there is no active session.
  #
  # @example
  #   before_action :require_login
  def require_login
    redirect_to(root_url) unless current_user
  end

  # The requsted time represents the time that a user is requesting entries be
  # loaded for or entries to be added under.
  #
  # @return [Time]
  def requested_time
    val = params[:requested_time]
    val.present? ? Time.at(val.to_i) : Time.current
  end

  # Find and return the ID of the "active" book. Looks at both a `book_id` and
  # an `id` param, in that order.
  #
  # @return [Integer]
  def current_book_id
    @current_book_id ||= params[:book_id] || params[:id]
  end

  # Find and return the current "active" book. This is scopes to the user's
  # books.
  #
  # @return [Book]
  def current_book
    @current_book ||= books.find(current_book_id)
  end

  # Return all of the current user's books.
  #
  # @return [Array<Book>]
  def books
    @books ||= current_user.books
  end
end
