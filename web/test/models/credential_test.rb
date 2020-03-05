require "test_helper"

class CredentialTest < ActiveSupport::TestCase
  test "save happy path" do
    assert credential.save
  end

  test "create_with_options creates an options for every key" do
    options = {
      :name1 => "Marcos1",
      :name2 => "Marcos2",
    }

    assert_equal CredentialOption.count, 0
    Credential.create_with_options(user, connection, options)
    assert_equal CredentialOption.count, 2
  end

  test "options returns all values" do
    options = {
      :name1 => "Marcos1",
      :name2 => "Marcos2",
    }

    credential = Credential.create_with_options(user, connection, options)
    options = credential.options
    keys = options.keys

    assert_equal ["name1", "name2"].sort, keys.sort
  end

  test "options returns decrypted values" do
    options = {
      :name1 => "Marcos1",
      :name2 => "Marcos2",
    }

    credential = Credential.create_with_options(user, connection, options)
    options = credential.options
    values = options.values

    assert_equal ["Marcos1", "Marcos2"].sort, values.sort
  end

private

  def user
    @user ||= create(:user)
  end

  def credential
    @credential ||= Credential.new(:user => user, :connection => connection)
  end

  def connection
    @connection ||= create(:connection, :user => user, :book => book)
  end

  def book
    @book ||= create(:book, :user => user)
  end
end
