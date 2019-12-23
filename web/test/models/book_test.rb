require "test_helper"

class BookTest < ActiveSupport::TestCase
  setup { travel_to "2019-05-21 14:32:53" }

  test "save happy path" do
    assert book.save
  end

  test "defaults to no grouping" do
    assert book.group_by_none?
  end

  test "grouping can be updated" do
    book.save
    book.group_by_day!

    assert book.group_by_day?
  end

  test "add entry with no grouping" do
    book(:grouping => :none).save
    entry = book.add_entry(:original_text => "hi")

    assert entry.persisted?
  end

  test "collections are reused" do
    book(:grouping => :none).save

    first_entry = book.add_entry(:original_text => "hi1")
    second_entry = book.add_entry(:original_text => "hi2")

    assert first_entry.collection_id == second_entry.collection_id
  end

  test "daily grouping does not match past collection" do
    book(:grouping => :day).save
    past_collection = Collection.create(:book => book, :datetime => Date.yesterday)

    first_entry = book.add_entry(:original_text => "hi1")
    second_entry = book.add_entry(:original_text => "hi2")

    assert past_collection.id != second_entry.collection_id
    assert first_entry.collection_id == second_entry.collection_id
  end

  test "daily grouping does not match future collection" do
    book(:grouping => :day).save
    past_collection = Collection.create(:book => book, :datetime => Date.tomorrow)

    first_entry = book.add_entry(:original_text => "hi1")
    second_entry = book.add_entry(:original_text => "hi2")

    assert past_collection.id != second_entry.collection_id
    assert first_entry.collection_id == second_entry.collection_id
  end

  test "expected collection is retrieved when multiple exist" do
    book(:grouping => :day)
    expected = collections_for(book)[:present]
    assert book.find_collection(Date.today).id = expected.id
  end

  test "expected collection is retrieved when multiple exist and a past time is requested" do
    book(:grouping => :day)
    expected = collections_for(book)[:past]
    assert book.find_collection(Date.yesterday).id = expected.id
  end

  test "expected collection is retrieved when multiple exist and a future time is requested" do
    book(:grouping => :day)
    expected = collections_for(book)[:future]
    assert book.find_collection(Date.tomorrow).id = expected.id
  end

  test "grouping prev/next times are correcly calculated for day group" do
    prev_time, next_time = book(:grouping => :day).grouping_prev_next_times(Date.today)
    assert_equal Date.yesterday, prev_time
    assert_equal Date.tomorrow, next_time
  end

private

  def book(overrides = {})
    @book ||= Book.new({ :user => user,
                         :name => "Testing" }.merge(overrides))
  end

  def user
    @user ||= User.new(:email => "test1@test.com",
                       :password => "xsj3k2lj4k3l2hio23321")
  end

  def collections_for(book)
    {
      :past => Collection.create(:book => book, :datetime => Date.yesterday),
      :future => Collection.create(:book => book, :datetime => Date.tomorrow),
      :present => Collection.create(:book => book, :datetime => Date.today),
    }
  end
end
