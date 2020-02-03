require "test_helper"

class ReportVariableTest < ActiveSupport::TestCase
  test "save happy path" do
    assert report_variable.save
  end

private

  def report
    @report ||= Report.new(:user => create(:user),
                           :label => "Testing")
  end

  def report_variable
    @report_variable ||= ReportVariable.new(:report => report,
                                            :label => "Testing")
  end
end
