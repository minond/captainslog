require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "history is saved on every action" do
    dummy_urls.each { |url| get url }
    dummy_urls.each_with_index { |url, index| assert_equal session_history_path_at(index), url }
  end

  test "session history urls can be retrieved" do
    dummy_urls.each { |url| get url }
    assert_equal "http://www.example.com/book/#{book.slug}", controller.send(:go_back_path, 1)
    assert_equal "http://www.example.com/user", controller.send(:go_back_path, 2)
    assert_equal "http://www.example.com/", controller.send(:go_back_path, 3)
  end

private

  # @return [Array<String>]
  def dummy_urls
    @dummy_urls ||= [
      "/",
      "/user",
      "/book/#{book.slug}"
    ]
  end

  # @param [Integer] index, position to get the session history path from
  # @return [String]
  def session_history_path_at(index)
    URI(controller.session[:history][index]).path
  end
end
