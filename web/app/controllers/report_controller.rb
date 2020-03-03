class ReportController < ApplicationController
  # === URL
  #   GET /report/new
  #
  # === Sample request
  #   /report/new
  #
  def new
    locals :report => Report.new
  end

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

  # === URL
  #   GET /report/:id/edit
  #
  # === Request fields
  #   [Integer] id - the id of the report to show
  #
  # === Sample request
  #   /report/4/edit
  #
  def edit
    locals :report => current_report
  end

  # === URL
  #   POST /report
  #
  # === Request fields
  #   [String] report[label] - the report label
  #
  # === Sample request
  #   /report
  #
  def create
    report = create_report
    ok = report.persisted?
    notify(ok, :successful_extractor_create, :failure_in_extractor_create)
    ok ? redirect_to(edit_report_path(report)) : locals(:new, :report => report)
  end

private

  param_reader :id

  # @return [Report]
  def current_report
    current_user.reports.find(id)
  end

  # @return [Report]
  def create_report
    extra = { :user => current_user }
    attrs = permitted_report_params.to_hash.merge(extra)
    Report.create(attrs)
  end

  # @return [ActionController::Parameters]
  def permitted_report_params
    params.require(:report)
          .permit(:label)
  end
end
