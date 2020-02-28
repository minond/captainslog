# rubocop:disable Lint/UselessAccessModifier
class ReportsController < ApplicationController
  respond_to :json

  # === URL
  #   GET /reports
  #
  # === Sample request
  #   /reports
  #
  def index
    locals :reports => current_user.reports
  end

  # === URL
  #   GET /reports/:id
  #
  # === Request fields
  #   [Integer] id - id of report to load
  #
  # === Sample request
  #   /reports/1
  #
  def show
    locals :report => current_user.reports.find(id)
  end

private

  param_reader :id
end
# rubocop:enable Lint/UselessAccessModifier
