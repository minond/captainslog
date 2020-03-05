require "test_helper"

class UserTest < ActiveSupport::TestCase
  @original_secret_key_base = nil

  setup do
    @original_secret_key_base = Rails.application.credentials.secret_key_base
    Rails.application.credentials.secret_key_base = "1" * 32
  end

  teardown do
    Rails.application.credentials.secret_key_base = @original_secret_key_base
  end

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

  test "homepage_options" do
    user = create(:user)
    create(:report, :user => user)
    create(:book, :user => user)
    assert_equal user.homepage_options.size, 2
  end
end
