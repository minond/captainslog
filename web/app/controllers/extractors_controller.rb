class ExtractorsController < ApplicationController
  before_action :require_login

  def show
    locals :extractor => current_extractor
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
end
