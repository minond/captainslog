require "test_helper"

class ProcessEntryJobTest < ActiveJob::TestCase
  test "updates text" do
    entry = build(:entry)
    process_entry_job.perform(entry)
    assert_equal "updated text", entry.text
  end

  test "updates data" do
    entry = build(:entry)
    process_entry_job.perform(entry)
    assert_equal "b", entry.data["a"]
  end

  def process_entry_job
    job = ProcessEntryJob.new
    job.processor = TestProcessor.new
    job
  end

  class TestProcessor
    def process(_entry)
      ["updated text", { :a => :b }]
    end
  end
end
