require 'test_helper'

class BookControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in(user) }

  def user
    @user ||= create(:user)
  end

  def book
    @book ||= create(:book, :user => user)
  end

  test "should get show page" do
    get "/book/#{book.id}"
    assert_response :success
  end
end
