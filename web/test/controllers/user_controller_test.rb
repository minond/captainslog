require "test_helper"

class UserControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user(:name => "My Name") }

  test "should show user information" do
    get "/user/#{user.id}"
    assert response.body.include?("My Name")
  end

  test "updating a user displays the correct information" do
    put "/user/#{user.id}", :params => { :user => { :name => "Updated Name" } }
    assert response.body.include?("Updated Name")
  end

  test "missing user information results in an error" do
    put "/user/#{user.id}", :params => { :user => { :email => "" } }
    assert response.body.include?("There was an error updating the user")
  end
end
