require "test_helper"

class ExtractorControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "it is able to load a resouce" do
    book = create(:book, :user => user)
    extractor = create(:extractor, :user => user, :book => book)
    get "/book/#{extractor.book.slug}/extractor/#{extractor.id}"
    assert_response :success
  end
end
