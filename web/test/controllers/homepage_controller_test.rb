require "test_helper"

class HomepageControllerTest < ActionDispatch::IntegrationTest
  test "renders the welcome page when there is no session" do
    get "/"
    assert response.body.include? "is an application for logging"
  end

  test "renders the home page when there is a session" do
    sign_in user
    get "/"
    assert_not response.body.include? "is an application for logging"
  end

  test "regirects to user's homepage" do
    user.update(:homepage => "/report/1")
    sign_in user
    get "/"
    assert_redirected_to "/report/1"
  end
end
