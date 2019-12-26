require "test_helper"

class ProcessEntryJobTest < ActiveJob::TestCase
  test "updates text" do
    entry = build(:entry)
    ProcessEntryJob.new.perform(entry, ProcessorTest::Runner.new)
    assert_equal "updated text", entry.text
  end

  test "updates data" do
    entry = build(:entry)
    ProcessEntryJob.new.perform(entry, ProcessorTest::Runner.new)
    assert_equal "b", entry.data["a"]
  end

  test "saves the entry" do
    entry = create(:entry)
    ProcessEntryJob.new.perform(entry, ProcessorTest::Runner.new)
    assert entry.persisted?
  end
end
