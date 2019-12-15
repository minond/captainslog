require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "save happy path" do
    assert user.save
  end

  def user(overrides = {})
    @user ||= User.new({:email => "test1@test.com",
                        :password => "xsj3k2lj4k3l2hio23321"}.merge(overrides))
  end
end
