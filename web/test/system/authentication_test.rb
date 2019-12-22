require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  setup { Rails.application.load_seed }

  test "sign in" do
    sign_in
    assert_text "Signed in successfully."
  end

  test "sign out" do
    sign_in
    click_on "Sign out"
    assert_text "Signed out successfully."
  end

  def sign_in
    visit root_path
    click_on "Sign in"
    fill_in "Email", :with => ENV["CAPTAINS_LOG_USERNAME"]
    fill_in "Password", :with => ENV["CAPTAINS_LOG_PASSWORD"]
    click_button "Log in"
  end
end
