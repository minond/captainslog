class ReportVariableController < ApplicationController
  # === URL
  #   GET /report/:report_id/report_variable/new
  #
  # === Sample request
  #   /report/12/report_variable/new
  #
  def new
    locals :report_variable => ReportVariable.new(:report => current_report)
  end

  # === URL
  #   GET /report/:report_id/report_variable/:id/edit
  #
  # === Request fields
  #   [Integer] report_id - the id of the owning report
  #   [Integer] id - the id of the report variable to edit
  #
  # === Sample request
  #   /report/4/report_variable/3/edit
  #
  def edit
    locals :report_variable => current_report_variable
  end

private

  param_reader :id
  param_reader :report_id

  # @return [Report]
  def current_report
    current_user.reports.find(report_id)
  end

  # @return [ReportVariable]
  def current_report_variable
    current_report.variables.find(id)
  end
end
