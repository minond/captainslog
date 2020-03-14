require "test_helper"

class JWTTest < ActiveSupport::TestCase
  test "encoding and decoding JWTs" do
    payload = { :name => "Marcos" }
    encoded = JWT.encode_application_token(payload)
    decoded = JWT.decode_application_token(encoded)
    assert_equal "Marcos", decoded[:name]
  end
end
