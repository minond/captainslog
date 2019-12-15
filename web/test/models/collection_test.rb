require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  test "save happy path" do
    coll = Collection.new(:book => books(:test_log))

    assert coll.save
  end

  test "closed by default" do
    coll = Collection.new(:book => books(:test_log))
    coll.save

    assert_not coll.open
  end

  test "can be opened" do
    coll = Collection.new(:book => books(:test_log), :open => true)
    coll.save

    assert coll.open
  end
end
