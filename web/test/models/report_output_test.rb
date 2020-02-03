require "test_helper"

class ReportOutputTest < ActiveSupport::TestCase
  test "save happy path" do
    assert report_output.save
  end

private

  def report
    @report ||= Report.new(:user => create(:user),
                           :label => "Testing")
  end

  def report_output
    @report_output ||= ReportOutput.new(:report => report,
                                        :kind => :chart,
                                        :label => "Testing")
  end
end
