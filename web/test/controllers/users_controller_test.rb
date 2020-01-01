require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user(:name => "My Name") }

  test "should show user information" do
    get "/user"
    assert response.body.include?("My Name")
  end

  test "updating a user displays the correct information" do
    put "/user", :params => { :user => { :name => "Updated Name" } }
    follow_redirect!
    assert response.body.include?("Updated Name")
  end

  test "missing user information results in an error" do
    put "/user", :params => { :user => { :email => "" } }
    follow_redirect!
    assert response.body.include?("There was an error updating the user")
  end
end
