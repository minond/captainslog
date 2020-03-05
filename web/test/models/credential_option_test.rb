require "test_helper"

class CredentialOptionTest < ActiveSupport::TestCase
  test "save happy path" do
    credential_option = CredentialOption.new(:credential => credential,
                                             :label => "key",
                                             :value => "value")
    assert credential_option.save
  end

  test "encrypts value" do
    credential_option = CredentialOption.new(:credential => credential,
                                             :label => "key",
                                             :value => "value")

    assert_not credential_option.value == "value"
  end

  test "dencrypts value" do
    credential_option = CredentialOption.new(:credential => credential,
                                             :label => "key",
                                             :value => "value")

    assert credential_option.decrypted_value == "value"
  end

private

  def user
    @user ||= create(:user)
  end

  def credential
    @credential ||= Credential.create(:user => user, :connection => connection)
  end

  def connection
    @connection ||= create(:connection, :user => user, :book => book)
  end

  def book
    @book ||= create(:book, :user => user)
  end
end
