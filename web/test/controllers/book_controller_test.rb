require 'test_helper'

class BookControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "should get show page" do
    get "/book/#{book.id}"
    assert_response :success
  end

  test "adding an entry" do
    assert_changes -> { Entry.count } do
      post "/book/#{book.id}/entry", :params => {:text => "hi"}
    end
  end

private

  def user
    @user ||= create(:user)
  end

  def book
    @book ||= create(:book, :user => user)
  end
end
