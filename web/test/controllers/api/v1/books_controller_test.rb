require "test_helper"

class ApiV1BooksControllerTest < ActionDispatch::IntegrationTest
  test "getting books" do
    user = create(:user)
    create_list(:book, 3, :user => user)
    get "/api/v1/books", as_user(user)
    assert_equal 3, JSON.parse(response.body).size
  end
end
