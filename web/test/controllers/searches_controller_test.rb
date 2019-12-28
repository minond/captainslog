require "test_helper"

class SearchesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "should get show page" do
    get "/search"
    assert_response :success
  end

  test "no results message" do
    get "/search?query=123"
    assert response.body.include? "There were no results"
  end

  test "matching entries owned by the active user are listed" do
    create(:entry, :user => user, :processed_text => "Running")
    get "/search?query=Running"
    assert response.body.include? "Running"
  end

  test "matching entries not owned by the active user are listed" do
    create(:entry, :user => create(:user), :processed_text => "Running")
    get "/search?query=Running"
    assert response.body.include? "There were no results"
  end
end
