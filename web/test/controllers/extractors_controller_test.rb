require "test_helper"

class ExtractorsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "it is able to load a resouce" do
    extractor = create(:extractor)
    get "/extractors/#{extractor.id}"
    assert_response :success
  end
end
