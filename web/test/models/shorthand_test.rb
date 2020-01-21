require "test_helper"

class ShorthandTest < ActiveSupport::TestCase
  test "save happy path" do
    assert shorthand.save
  end

private

  # @return [Shorthand]
  def shorthand
    Shorthand.new(:book => create(:book),
                  :user => create(:user),
                  :priority => 1,
                  :expansion => "a")
  end
end
