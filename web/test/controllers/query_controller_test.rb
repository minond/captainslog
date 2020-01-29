require "test_helper"

class QueryControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "making a request" do
    with_mocked_querier do |mock|
      mock.expect(:run, nil)
      post "/query/execute", :params => { :query => "select 1 from 2" }
      assert_response :success
    end
  end

  test "it returns the response from the runner" do
    with_mocked_querier do |mock|
      mock.expect(:run, "results go here")
      post "/query/execute", :params => { :query => "select 1 from 2" }
      assert response.body.include? "results go here"
    end
  end

  test "it passes the active user to the runner" do
    with_mocked_querier(proc { |*args|
      assert_equal user.id, args[0]
    }) do |mock|
      mock.expect(:run, nil)
      post "/query/execute", :params => { :query => "select 1 from 2" }
    end
  end

  test "it passes the query to the runner" do
    with_mocked_querier(proc { |*args|
      assert_equal "select 1 from 2", args[1]
    }) do |mock|
      mock.expect(:run, nil)
      post "/query/execute", :params => { :query => "select 1 from 2" }
    end
  end

private

  # This helper method will return a value that ensure a stubbed method always
  # gets a mock. It optionally wraps a user-defined method in the callback and
  # passed the stubbed method's arguments to it.
  #
  # @param [Minitest::Mock] mock
  # @param [Lambda] callback
  # @return [Lambda | Minitest::Mock]
  def stubbed_value_wrapper(mock, callback)
    if callback.nil?
      mock
    else
      lambda do |*args|
        callback.call(*args)
        mock
      end
    end
  end

  # @param [implements #call] callback
  # @param [Block]
  def with_mocked_querier(callback = nil)
    mock = Minitest::Mock.new
    Querier::Runner.stub :new, stubbed_value_wrapper(mock, callback) do
      yield(mock)
    end
  end
end
