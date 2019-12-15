require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "save happy path" do
    user = User.new(:email => "test1@test.com",
                    :password => "xsj3k2lj4k3l2hio23321")

    assert user.save
  end
end
