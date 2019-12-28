require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "renders the welcome page when there is no session" do
    get "/"
    assert response.body.include? "is an application for logging"
  end

  test "renders the home page when there is a session" do
    sign_in user
    get "/"
    assert response.body.include? "Sign out"
  end
end
