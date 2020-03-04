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

  # === URL
  #   POST /report/:report_id/report_variable
  #
  # === Request fields
  #   [Integer] report_id - the report to add the variable to
  #   [String] report_variable[label] - the report variable's label
  #   [String] report_variable[default_value] - the report variable's default value
  #   [String] report_variable[query] - the report variable's query
  #
  # === Sample request
  #   /report/12/report_variable
  #
  def create
    report_variable = create_report_variable
    ok = report_variable.persisted?
    notify(ok, :successful_report_variable_create, :failure_in_report_variable_create)
    ok ? redirect_to(edit_report_path(current_report)) : locals(:new, :report_variable => report_variable)
  end

  # === URL
  #   PATCH /report/:report_id/report_variable/:id
  #
  # === Request fields
  #   [Integer] report_id - the report that the variable belongs to
  #   [Integer] id - the report variable to update
  #   [String] report_variable[label] - the report variable's label
  #   [String] report_variable[default_value] - the report variable's default value
  #   [String] report_variable[query] - the report variable's query
  #
  # === Sample request
  #   /report/12/report_variable/2
  #
  def update
    ok = update_report_variable
    notify(ok, :successful_report_variable_update, :failure_in_report_variable_update)
    ok ? redirect_to(edit_report_path(current_report)) : locals(:edit, :report_variable => current_report_variable)
  end

  # === URL
  #   DELETE /report/:report_id/report_variable/:id
  #
  # === Request fields
  #   [Integer] report_id - the report that the variable belongs to
  #   [Integer] id - the report variable to update
  #
  # === Sample request
  #   /report/12/report_variable/2
  #
  def destroy
    current_report_variable.destroy
    flash.notice = t(:successful_report_variable_delete)
    redirect_to(edit_report_path(current_report))
  end

private

  param_reader :id
  param_reader :report_id

  # @return [ReportVariable]
  def create_report_variable
    extra = { :report => current_report }
    attrs = permitted_report_variable_params.to_hash.merge(extra)
    ReportVariable.create(attrs)
  end

  # @return [Report]
  def current_report
    current_user.reports.find(report_id)
  end

  # @return [ReportVariable]
  def current_report_variable
    current_report.variables.find(id)
  end

  # Update the report variable and return true if there were not errors doing so.
  #
  # @return [Boolean]
  def update_report_variable
    current_report_variable.update(permitted_report_variable_params)
    current_report_variable.errors.empty?
  end

  # @return [ActionController::Parameters]
  def permitted_report_variable_params
    params.require(:report_variable)
          .permit(:label, :default_value, :query)
  end
end
