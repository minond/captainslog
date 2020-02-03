require "test_helper"

class ReportTest < ActiveSupport::TestCase
  test "save happy path" do
    assert report.save
  end

private

  def report
    @report ||= Report.new(:user => create(:user),
                           :label => "Testing")
  end
end
