require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "save happy path" do
    user = User.new(:email => "test1@test.com", :password => "xsj3k2lj4k3l2hio23321")
    assert user.save
  end

  test "encryption and decryption" do
    original = "testing123"
    user = create(:user)
    encrypted = user.encrypt_value(original)
    decrypted = user.decrypt_value(encrypted)
    assert_equal decrypted, original
  end
end
