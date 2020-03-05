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

#   test "create_with_options creates an options for every key" do
#     options = {
#       :name1 => "Marcos1",
#       :name2 => "Marcos2",
#     }
#
#     assert_equal CredentialOption.count, 0
#     Credential.create_with_options(user, connection, options)
#     assert_equal CredentialOption.count, 2
#   end
#
#   test "options returns all values" do
#     options = {
#       :name1 => "Marcos1",
#       :name2 => "Marcos2",
#     }
#
#     credential = Credential.create_with_options(user, connection, options)
#     options = credential.options
#     keys = options.keys
#
#     assert_equal %w[name1 name2].sort, keys.sort
#   end
#
#   test "options returns decrypted values" do
#     options = {
#       :name1 => "Marcos1",
#       :name2 => "Marcos2",
#     }
#
#     credential = Credential.create_with_options(user, connection, options)
#     options = credential.options
#     values = options.values
#
#     assert_equal %w[Marcos1 Marcos2].sort, values.sort
#   end

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
