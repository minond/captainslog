class ExtractorController < ApplicationController
  before_action :require_login

  # === URL
  #   GET /book/:book_slug/extractors/:id
  #
  # === Sample request
  #   /book/workouts/extractors/1
  #
  def show
    locals :extractor => current_extractor
  end

  # === URL
  #   PATCH /book/:book_slug/extractors/:id
  #
  # === Request fields
  #   [String] extractor[label] - the extractor label
  #   [String] extractor[match] - the extractor match
  #   [Integer] extractor[type] - the extractor type
  #
  # === Sample request
  #   /book/workouts/extractors/1?label=mylabel
  #
  def update
    ok = update_extractor
    notify(ok, :successful_extractor_update, :failure_in_extractor_update)
    ok ? redirect_to(current_extractor) : locals(:show, :extractor => current_extractor)
  end

private

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
