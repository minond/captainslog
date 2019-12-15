require 'test_helper'

class BookTest < ActiveSupport::TestCase
  test "save happy path" do
    assert book.save
  end

  def book(overrides = {})
    @book ||= Book.new({:user => users(:plain),
                        :name => "Testing",
                        :grouping => 1}.merge(overrides))
  end
end
