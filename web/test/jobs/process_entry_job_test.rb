require 'test_helper'

class ProcessEntryJobTest < ActiveJob::TestCase
  test "calls out to external processor" do
    entry = build(:entry)
    job = ProcessEntryJob.new
    job.perform(entry)
    assert entry.data["created_at"]
  end
end
