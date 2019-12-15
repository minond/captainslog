require 'test_helper'

class BookTest < ActiveSupport::TestCase
  test "save happy path" do
    book = Book.new(:user => users(:plain),
                    :name => "Testing",
                    :grouping => 1)

    assert book.save
  end
end
