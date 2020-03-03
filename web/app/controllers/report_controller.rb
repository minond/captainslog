class ReportController < ApplicationController
  # === URL
  #   GET /report/:id
  #
  # === Request fields
  #   [Integer] id - the id of the report to show
  #
  # === Sample request
  #   /report/4
  #
  def show
    locals :report => current_report
  end

private

  param_reader :id

  # @return [Report]
  def current_report
    current_user.reports.find(id)
  end
end
