require "test_helper"

class EntryControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "it can show an entry" do
    entry = create(:entry, :user => user)
    get "/book/#{entry.book.slug}/entry/#{entry.id}"
    assert_response :success
  end

  test "is can create an entry and schedules processing" do
    assert_enqueued_jobs 1 do
      post "/book/#{create(:book, :user => user).slug}/entry", :params => { :text => "hi" }
    end
  end

  test "it can update entries and scheduled reprocessins" do
    assert_enqueued_jobs 2 do
      entry = create(:entry, :user => user, :original_text => "original")
      patch "/book/#{entry.book.slug}/entry/#{entry.id}", :params => { :original_text => "update" }
      entry.reload
    end
  end

  test "it can destroy an entry" do
    entry = create(:entry, :user => user)
    delete "/book/#{entry.book.slug}/entry/#{entry.id}"
    assert_response :redirect
  end

  test "it fails to delete an entry not owned by the active user" do
    entry = create(:entry, :user => create(:user))
    assert_raises(ActiveRecord::RecordNotFound) { delete "/book/#{entry.book.slug}/entry/#{entry.id}" }
  end

  test "it redirects to the home page by default" do
    entry = create(:entry, :user => user)
    redirect = entry.collection_path
    delete "/book/#{entry.book.slug}/entry/#{entry.id}"
    assert_redirected_to redirect
  end
end
