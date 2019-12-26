require "test_helper"

class ProcessEntryJobTest < ActiveJob::TestCase
  test "updates text" do
    entry = build(:entry)
    ProcessEntryJob.new.perform(entry, TestProcessor.new)
    assert_equal "updated text", entry.text
  end

  test "updates data" do
    entry = build(:entry)
    ProcessEntryJob.new.perform(entry, TestProcessor.new)
    assert_equal "b", entry.data["a"]
  end

  class TestProcessor
    def process(_entry)
      ["updated text", { :a => :b }]
    end
  end
end
