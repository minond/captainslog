require "test_helper"

class ReportTest < ActiveSupport::TestCase
  test "save happy path" do
    assert report.save
  end

  test "dump report information" do
    report, _variable, _output, dumped = dumped_report
    assert_equal dumped[:id], report.id
    assert_equal dumped[:label], report.label
  end

  test "dump report variable information" do
    _report, variable, _output, dumped = dumped_report
    assert_equal dumped[:variables].first[:id], variable.id
    assert_equal dumped[:variables].first[:label], variable.label
    assert_equal dumped[:variables].first[:query], variable.query
    assert_equal dumped[:variables].first[:defaultValue], variable.default_value
  end

  test "dump report output information" do
    _report, _variable, output, dumped = dumped_report
    assert_equal dumped[:outputs].first[:id], output.id
    assert_equal dumped[:outputs].first[:label], output.label
    assert_equal dumped[:outputs].first[:kind], output.kind
    assert_equal dumped[:outputs].first[:width], output.width
    assert_equal dumped[:outputs].first[:height], output.height
    assert_equal dumped[:outputs].first[:query], output.query
  end

private

  def report
    @report ||= Report.new(:user => create(:user),
                           :label => "Testing")
  end

  def dumped_report
    report = create(:report)
    variable = create(:report_variable, :report => report)
    output = create(:report_output, :report => report)
    dumped = report.dump
    [report, variable, output, dumped]
  end
end
