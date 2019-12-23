require "test_helper"

class EntryTest < ActiveSupport::TestCase
  test "save happy path" do
    assert entry.save
  end

  test "processed text is favored over the original text" do
    assert_equal "a", entry(:processed_text => "a", :original_text => "b").text
  end

  test "original text is used when processed text is not set" do
    assert_equal "b", entry(:processed_text => nil, :original_text => "b").text
  end

private

  def entry(overrides = {})
    @entry ||= Entry.new({ :book => book,
                           :collection => collection,
                           :original_text => "hi" }.merge(overrides))
  end

  def book
    @book ||= Book.new(:user => create(:user),
                       :name => "Testing")
  end

  def collection
    @collection ||= Collection.new(:book => book, :datetime => Time.current)
  end
end
