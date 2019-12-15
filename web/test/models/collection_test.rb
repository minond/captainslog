require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  test "save happy path" do
    assert collection.save
  end

  test "closed by default" do
    collection.save

    assert_not collection.open
  end

  test "can be opened" do
    collection(:open => true)
    collection.save

    assert collection.open
  end

  def collection(overrides = {})
    @collection ||= Collection.new({:book => books(:test_log)}.merge(overrides))
  end
end
