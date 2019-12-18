require "test_helper"

class EntryTest < ActiveSupport::TestCase
  test "save happy path" do
    assert entry.save
  end

private

  def entry
    @entry ||= Entry.new(:book => book,
                         :collection => collection,
                         :original_text => "hi")
  end

  def book
    @book ||= Book.new(:user => user,
                       :name => "Testing")
  end

  def collection
    @collection ||= Collection.new(:book => book)
  end

  def user
    @user ||= User.new(:email => "test1@test.com",
                       :password => "xsj3k2lj4k3l2hio23321")
  end
end
