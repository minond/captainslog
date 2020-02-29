require "test_helper"

class ShorthandControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "it is able to load a resouce" do
    book = create(:book, :user => user)
    shorthand = create(:shorthand, :user => user, :book => book)
    get "/book/#{shorthand.book.slug}/shorthand/#{shorthand.id}"
    assert_response :success
  end
end
