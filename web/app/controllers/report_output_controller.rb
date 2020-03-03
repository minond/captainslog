class ReportOutputController < ApplicationController
  # === URL
  #   GET /report/:report_id/report_output/new
  #
  # === Sample request
  #   /report/12/report_output/new
  #
  def new
    locals :report_output => ReportOutput.new(:report => current_report)
  end

  # === URL
  #   GET /report/:report_id/report_output/:id/edit
  #
  # === Request fields
  #   [Integer] report_id - the id of the owning report
  #   [Integer] id - the id of the report output to edit
  #
  # === Sample request
  #   /report/4/report_output/3/edit
  #
  def edit
    locals :report_output => current_report_output
  end

private

  param_reader :id
  param_reader :report_id

  # @return [Report]
  def current_report
    current_user.reports.find(report_id)
  end

  # @return [ReportOutput]
  def current_report_output
    current_report.outputs.find(id)
  end
end
