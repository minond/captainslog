require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, :using => :chrome, :screen_size => [1400, 1400]

  def sign_in
    visit root_path
    fill_in "Email", :with => ENV["CAPTAINS_LOG_USERNAME"]
    fill_in "Password", :with => ENV["CAPTAINS_LOG_PASSWORD"]
    click_button "Sign in"
  end

  def sign_out
    go_to_user_page
    click_on "Sign out"
  end

  def go_to_user_page
    find("[data-testing=userpage]").click
  end
end
