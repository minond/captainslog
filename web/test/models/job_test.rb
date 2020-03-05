require "test_helper"

class JobTest < ActiveSupport::TestCase
  test "save happy path" do
    job = Job.new(:user => create(:user),
                  :status => :initiated,
                  :args => "null",
                  :kind => :connection_data_pull_standard)
    assert job.save
  end
end
