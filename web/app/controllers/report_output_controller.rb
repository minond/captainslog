class ReportOutputController < UserSessionController
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

  # === URL
  #   POST /report/:report_id/report_output
  #
  # === Request fields
  #   [Integer] report_id - the report to add the output to
  #   [String] report_output[label] - the report output's label
  #   [String] report_output[default_value] - the report output's default value
  #   [String] report_output[query] - the report output's query
  #
  # === Sample request
  #   /report/12/report_output
  #
  def create
    report_output = create_report_output
    ok = report_output.persisted?
    notify(ok, :successful_report_output_create, :failure_in_report_output_create)
    ok ? redirect_to(edit_report_path(current_report)) : locals(:new, :report_output => report_output)
  end

  # === URL
  #   PATCH /report/:report_id/report_output/:id
  #
  # === Request fields
  #   [Integer] report_id - the report that the output belongs to
  #   [Integer] id - the report output to update
  #   [String] report_output[label] - the report output's label
  #   [String] report_output[default_value] - the report output's default value
  #   [String] report_output[query] - the report output's query
  #
  # === Sample request
  #   /report/12/report_output/2
  #
  def update
    ok = update_report_output
    notify(ok, :successful_report_output_update, :failure_in_report_output_update)
    ok ? redirect_to(edit_report_path(current_report)) : locals(:edit, :report_output => current_report_output)
  end

  # === URL
  #   DELETE /report/:report_id/report_output/:id
  #
  # === Request fields
  #   [Integer] report_id - the report that the output belongs to
  #   [Integer] id - the report output to update
  #
  # === Sample request
  #   /report/12/report_output/2
  #
  def destroy
    current_report_output.destroy
    flash.notice = t(:successful_report_output_delete)
    redirect_to(edit_report_path(current_report))
  end

private

  param_reader :id
  param_reader :report_id

  # @return [ReportOutput]
  def create_report_output
    extra = { :report => current_report }
    attrs = permitted_report_output_params.to_hash.merge(extra)
    ReportOutput.create(attrs)
  end

  # @return [Report]
  def current_report
    current_user.reports.find(report_id)
  end

  # @return [ReportOutput]
  def current_report_output
    current_report.outputs.find(id)
  end

  # Update the report output and return true if there were not errors doing so.
  #
  # @return [Boolean]
  def update_report_output
    current_report_output.update(permitted_report_output_params)
    current_report_output.errors.empty?
  end

  # @return [ActionController::Parameters]
  def permitted_report_output_params
    params.require(:report_output)
          .permit(:label, :width, :height, :kind, :query, :order)
  end
end
