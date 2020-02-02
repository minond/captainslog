class ShorthandController < ApplicationController
  before_action :require_login

  # === URL
  #   GET /book/:slug/shorthand/new
  #
  # === Request fields
  #   [String] slug - the slug for the book the shorthand belongs to
  #
  # === Sample request
  #   /book/workouts/shorthand/new
  #
  def new
    locals :shorthand => Shorthand.new(:book => current_book)
  end

  # === URL
  #   POST /book/:slug/shorthand
  #
  # === Request fields
  #   [String] slug - the slug for the book the shorthand belongs to
  #   [Integer] shorthand[priority] - priority number
  #   [String] shorthand[expansion] - the shorthand expansion
  #   [String] shorthand[match] - the shorthand match
  #   [String] shorthand[text] - the shorthand text
  #
  # === Sample request
  #   /book/workouts/shorthand
  #
  def create
    shorthand = create_shorthand
    ok = shorthand.persisted?
    notify(ok, :successful_shorthand_create, :failure_in_shorthand_create)
    ok ? redirect_to(edit_book_path(current_book.slug)) : locals(:new, :shorthand => shorthand)
  end

  # === URL
  #   GET /book/:slug/shorthand/:id
  #
  # === Request fields
  #   [String] slug - the slug for the book the shorthand belongs to
  #   [Integer] id - the id for the shorthand to show
  #
  # === Sample request
  #   /book/workouts/shorthand/1
  #
  def show
    locals :shorthand => current_shorthand
  end

  # === URL
  #   PATCH /book/:slug/shorthand/:id
  #
  # === Request fields
  #   [String] slug - the slug for the book the shorthand belongs to
  #   [Integer] id - the id for the shorthand to update
  #   [Integer] shorthand[priority] - priority number
  #   [String] shorthand[expansion] - the shorthand expansion
  #   [String] shorthand[match] - the shorthand match
  #   [String] shorthand[text] - the shorthand text
  #
  # === Sample request
  #   /book/workouts/shorthand/1?expansion=ok
  #
  def update
    ok = update_shorthand
    notify(ok, :successful_shorthand_update, :failure_in_shorthand_update)
    ok ? redirect_to(current_shorthand) : locals(:show, :shorthand => current_shorthand)
  end

private

  # @return [Shorthand]
  def create_shorthand
    extra = {
      :user => current_user,
      :book => current_book
    }

    attrs = permitted_shorthand_params.to_hash.merge(extra)
    Shorthand.create(attrs)
  end

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

  # @param [Shorthand] shorthand
  # @return [String]
  def shorthand_url(shorthand)
    book_shorthand_path(shorthand.book.slug, shorthand.id)
  end
end
