require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "save happy path" do
    assert entry.save
  end

private

  def entry(overrides = {})
    @entry ||= Entry.new({:book => books(:test_log),
                          :collection => collections(:test_log_current),
                          :original_text => "hi"}.merge(overrides))
  end
end
