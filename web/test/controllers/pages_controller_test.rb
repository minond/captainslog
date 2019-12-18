require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home page" do
    get "/"
    assert_response :success
  end
end
