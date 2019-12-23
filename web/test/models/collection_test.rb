require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  test "save happy path" do
    assert collection.save
  end

private

  def collection(overrides = {})
    @collection ||= Collection.new({ :book => create(:book), :datetime => Time.current }.merge(overrides))
  end
end
