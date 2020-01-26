require "test_helper"

class ExternalServiceResponseTest < ActiveSupport::TestCase
  test "#ok?" do
    assert ExternalService::Response.new(ExternalServiceTestHelper::HTTPResponse.new("200")).ok?
    assert_not ExternalService::Response.new(ExternalServiceTestHelper::HTTPResponse.new).ok?
    assert_not ExternalService::Response.new(ExternalServiceTestHelper::HTTPResponse.new("400")).ok?
  end

  test "#code" do
    assert_equal "201", ExternalService::Response.new(ExternalServiceTestHelper::HTTPResponse.new("201")).code
  end

  test "#body" do
    assert_equal "bod", ExternalService::Response.new(ExternalServiceTestHelper::HTTPResponse.new("201", "bod")).body
  end
end
