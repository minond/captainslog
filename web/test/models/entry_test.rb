require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "save happy path" do
    entry = Entry.new(:book => books(:test_log),
                      :collection => collections(:test_log_current),
                      :original_text => "hi")

    assert entry.save
  end
end
