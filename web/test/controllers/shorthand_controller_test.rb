require "test_helper"

class ShorthandControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "it is able to load a resouce" do
    shorthand = create(:shorthand, :user => user)
    get "/book/#{shorthand.book.slug}/shorthand/#{shorthand.id}"
    assert_response :success
  end
end
