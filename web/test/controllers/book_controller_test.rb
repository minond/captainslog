require 'test_helper'

class BookControllerTest < ActionDispatch::IntegrationTest
  test "should get show page" do
    get book_path(books(:test_log))
    assert_response :success
  end
end
