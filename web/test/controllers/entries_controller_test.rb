require "test_helper"

class EntriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "it can destroy an entry owned" do
    entry = create(:entry, :user => user)
    delete "/entries/#{entry.id}"
    assert_response :redirect
  end

  test "it fails to delete an entry not owned by the active user" do
    entry = create(:entry, :user => create(:user))
    assert_raises(ActiveRecord::RecordNotFound) { delete "/entries/#{entry.id}" }
  end

  test "it redirects to the home page by default" do
    entry = create(:entry, :user => user)
    delete "/entries/#{entry.id}"
    assert_redirected_to "/"
  end

  test "it redirects to the referer if there is one" do
    entry = create(:entry, :user => user)
    delete "/entries/#{entry.id}", :headers => { :referer => "/here" }
    assert_redirected_to "/here"
  end
end
