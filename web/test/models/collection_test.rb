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

private

  def book
    @book ||= Book.new(:user => user,
                       :name => "Testing")
  end

  def collection(overrides = {})
    @collection ||= Collection.new({:book => book}.merge(overrides))
  end

  def user
    @user ||= User.new(:email => "test1@test.com",
                       :password => "xsj3k2lj4k3l2hio23321")
  end
end
