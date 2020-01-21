require "test_helper"

class ProcessEntryJobTest < ActiveJob::TestCase
  test "updates text" do
    entry = create(:entry)
    ProcessEntryJob.new.perform(entry, ProcessorTestHelper::Runner.new)
    entry_from_db = Entry.find(entry.id)
    assert_equal "updated text", entry_from_db.text
  end

  test "updates data" do
    entry = create(:entry)
    ProcessEntryJob.new.perform(entry, ProcessorTestHelper::Runner.new)
    entry_from_db = Entry.find(entry.id)
    assert_equal "b", entry_from_db.data["a"]
  end

  test "saves the entry" do
    entry = create(:entry)
    ProcessEntryJob.new.perform(entry, ProcessorTestHelper::Runner.new)
    assert entry.persisted?
  end
end
