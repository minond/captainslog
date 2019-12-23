require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  test "save happy path" do
    assert collection.save
  end

private

  def book
    @book ||= Book.new(:user => create(:user),
                       :name => "Testing")
  end

  def collection(overrides = {})
    @collection ||= Collection.new({ :book => book, :datetime => Time.current }.merge(overrides))
  end
end
