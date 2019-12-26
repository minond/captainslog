require "test_helper"

class ProcessEntryJobTest < ActiveJob::TestCase
  test "calls out to external processor" do
    entry = build(:entry)
    process_entry_job.perform(entry)
    assert_equal "updated text", entry.text
  end

  def process_entry_job
    job = ProcessEntryJob.new
    job.processor = TestProcessor.new
    job
  end

  class TestProcessor
    def process(entry)
      ["updated text", {:a => "a"}]
    end
  end
end
