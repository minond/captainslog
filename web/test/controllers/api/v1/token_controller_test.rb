require "test_helper"

class ApiV1TokenControllerTest < ActionDispatch::IntegrationTest
  test "getting a jwt" do
    user = create(:user)
    assert get_jwt(user)
  end

  test "failure to authenticate" do
    user = create(:user)
    params = { :email => user.email, :password => "invalid" }
    post "/api/v1/token", :params => params
    assert_response :unauthorized
  end
end
