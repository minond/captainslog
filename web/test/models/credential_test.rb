require "test_helper"

class CredentialTest < ActiveSupport::TestCase
  test "save happy path" do
    assert credential.save
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
