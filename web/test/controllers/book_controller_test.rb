require "test_helper"

class BookControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "should get show page" do
    get "/book/#{book.slug}"
    assert_response :success
  end

  test "adding an entry" do
    assert_changes -> { Entry.count } do
      post "/book/#{book.slug}/entry", :params => { :text => "hi" }
    end
  end
end
