require "test_helper"

class ShorthandsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "it is able to load a resouce" do
    shorthand = create(:shorthand)
    get "/shorthands/#{shorthand.id}"
    assert_response :success
  end
end
