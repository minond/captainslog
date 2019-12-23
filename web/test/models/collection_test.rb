require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  test "save happy path" do
    collection = Collection.new(:book => create(:book), :datetime => Time.current)
    assert collection.save
  end
end
