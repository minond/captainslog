require "test_helper"

class ShorthandTest < ActiveSupport::TestCase
  test "save happy path" do
    assert shorthand.save
  end

private

  # @return [Shorthand]
  def shorthand
    user = create(:user)
    book = create(:book, :user => user)
    Shorthand.new(:book => book,
                  :user => user,
                  :priority => 1,
                  :expansion => "a")
  end
end
