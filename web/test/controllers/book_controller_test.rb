require "test_helper"

class BookControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "show get the new page" do
    get "/book/new"
    assert_response :success
  end

  test "should get show page" do
    get "/book/#{book.slug}"
    assert_response :success
  end

  test "adding an entry" do
    assert_changes -> { Entry.count } do
      post "/book/#{book.slug}/entry", :params => { :text => "hi" }
    end
  end

  test "succesfully creating a new book" do
    assert_changes -> { Book.count } do
      post "/book", :params => {
        :book => {
          :name => "Testing",
          :slug => "testing",
          :grouping => :none,
        }
      }
    end
  end

  test "failure in creating a book results in an error message" do
    post "/book", :params => {
      :book => {
        :name => book.name,
        :slug => book.slug,
        :grouping => book.grouping,
      }
    }

    assert response.body.include? "There was an error creating the book."
  end

  test "succesfully updating a book" do
    patch "/book/#{book.slug}", :params => {
      :book => {
        :name => "Updated Name"
      }
    }

    assert_equal book.reload.name, "Updated Name"
  end

  test "failure in updating a book results in an error message" do
    create(:book, :user => user, :slug => "testing123")

    patch "/book/#{book.slug}", :params => {
      :book => {
        :slug => "testing123"
      }
    }

    follow_redirect!
    assert response.body.include? "There was an error updating the book."
  end

  test "deleting a book" do
    delete "/book/#{book.slug}"
    follow_redirect!
    assert_response :success
  end

  test "deleting a book owned by another user" do
    other_user = create(:user)
    other_book = create(:book, :user => other_user,
                               :slug => "blah")

    assert_raises(ActiveRecord::RecordNotFound) { delete "/book/#{other_book.slug}" }
  end
end
