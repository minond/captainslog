require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  setup { Rails.application.load_seed }

  test "sign in" do
    sign_in
    assert_text "Signed in successfully."
  end

  test "sign out" do
    sign_in
    sign_out
    assert_text "Signed out successfully."
  end
end
