require "test_helper"

class EntryTest < ActiveSupport::TestCase
  setup { travel_to "2019-05-21 14:32:53" }

  test "save happy path" do
    assert entry.save
  end

  test "processed text is favored over the original text" do
    assert_equal "a", entry(:processed_text => "a", :original_text => "b").text
  end

  test "original text is used when processed text is not set" do
    assert_equal "b", entry(:processed_text => nil, :original_text => "b").text
  end

  test "processed data is reset when making updates to original text" do
    entry.update(:processed_text => "test")
    assert_equal entry.processed_text, "test"
    entry.update(:original_text => "test")
    assert_nil entry.processed_text
  end

  test ".collection_path includes slug and collection time" do
    assert_equal "/book/#{entry.book.slug}/at/1558396800", entry.collection_path
  end

private

  def book
    @book ||= create(:book)
  end

  def collection
    create(:collection, :book => book)
  end

  def entry(overrides = {})
    @entry ||= Entry.create({ :book => book,
                              :user => book.user,
                              :collection => collection,
                              :original_text => "hi" }.merge(overrides))
  end
end
