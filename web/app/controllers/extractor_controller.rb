class ExtractorController < ApplicationController
  before_action :require_login

  # === URL
  #   GET /book/:slug/extractor/new
  #
  # === Request fields
  #   [String] slug - the slug for the book the extractor belongs to
  #
  # === Sample request
  #   /book/workouts/extractor/new
  #
  def new
    locals :extractor => Extractor.new(:book => current_book)
  end

  # === URL
  #   POST /book/:slug/extractor
  #
  # === Request fields
  #   [String] slug - the slug for the book the extractor belongs to
  #   [String] extractor[label] - the extractor label
  #   [String] extractor[match] - the extractor match
  #   [Integer] extractor[type] - the extractor type
  #
  # === Sample request
  #   /book/workouts/extractor
  #
  def create
    extractor = create_extractor
    ok = extractor.persisted?
    notify(ok, :successful_extractor_create, :failure_in_extractor_create)
    ok ? redirect_to(edit_book_path(current_book.slug)) : locals(:new, :extractor => extractor)
  end

  # === URL
  #   GET /book/:slug/extractor/:id
  #
  # === Request fields
  #   [String] slug - the slug for the book the extractor belongs to
  #   [Integer] id - the id for the extractor to show
  #
  # === Sample request
  #   /book/workouts/extractor/1
  #
  def show
    locals :extractor => current_extractor
  end

  # === URL
  #   PATCH /book/:slug/extractor/:id
  #
  # === Request fields
  #   [String] slug - the slug for the book the extractor belongs to
  #   [Integer] id - the id for the extractor to update
  #   [String] extractor[label] - the extractor label
  #   [String] extractor[match] - the extractor match
  #   [Integer] extractor[type] - the extractor type
  #
  # === Sample request
  #   /book/workouts/extractor/1?label=mylabel
  #
  def update
    ok = update_extractor
    notify(ok, :successful_extractor_update, :failure_in_extractor_update)
    ok ? redirect_to(current_extractor) : locals(:show, :extractor => current_extractor)
  end

  # === URL
  #   DELETE /book/:slug/extractor/:id
  #
  # === Request fields
  #   [String] slug - the slug for the book the extractor belongs to
  #   [Integer] id - the id for the extractor to delete
  #
  # === Sample request
  #   /book/slugit/extractor/12
  #
  def destroy
    current_extractor.destroy
    flash.notice = t(:successful_extractor_delete)
    redirect_to(edit_book_path(current_book.slug))
  end

private

  # @return [Extractor]
  def create_extractor
    extra = {
      :user => current_user,
      :book => current_book
    }

    attrs = permitted_extractor_params.to_hash.merge(extra)
    Extractor.create(attrs)
  end

  # Find and return the current "active" extractor. This is scopes to the
  # user's extractors.
  #
  # @return [Extractor]
  def current_extractor
    @current_extractor ||= Extractor.find_by!(:user => current_user,
                                              :id => params[:id])
  end

  # Update the extractor and return true if there were not errors doing so.
  #
  # @return [Boolean]
  def update_extractor
    current_extractor.update(permitted_extractor_params)
    current_extractor.errors.empty?
  end

  # @return [ActionController::Parameters]
  def permitted_extractor_params
    params.require(:extractor)
          .permit(:label, :match, :type)
  end

  # @param [Extractor] extractor
  # @return [String]
  def extractor_url(extractor)
    book_extractor_path(extractor.book.slug, extractor.id)
  end
end
