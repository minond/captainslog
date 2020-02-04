class ReportsController < ApplicationController
  before_action :require_login

  respond_to :json

  # === URL
  #   GET /reports
  #
  # === Sample request
  #   /reports
  #
  def index
    locals :reports => user_reports
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
    locals :report => current_report
  end

private

  # @return [Array<Report>]
  def user_reports
    Report.by_user(current_user)
  end

  # @return [Report]
  def current_report
    Report.by_user(current_user)
          .by_id(current_report_id)
  end

  # @return [Integer]
  def current_report_id
    params[:id]
  end
end
