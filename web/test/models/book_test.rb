require 'test_helper'

class BookTest < ActiveSupport::TestCase
  test "save happy path" do
    assert book.save
  end

  test "defaults to no grouping" do
    assert book.group_by_none?
  end

  test "grouping can be updated" do
    book.save
    book.group_by_day!

    assert book.group_by_day?
  end

  def book(overrides = {})
    @book ||= Book.new({:user => users(:plain),
                        :name => "Testing"}.merge(overrides))
  end
end
