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
    entry = book.add_entry("hi")

    assert entry.persisted?
  end

  test "adding entries that use the same collection in the present" do
    book(:grouping => :none).save

    first_entry = book.add_entry("hi1")
    second_entry = book.add_entry("hi2")

    assert first_entry.collection_id == second_entry.collection_id
  end

  test "adding entries that use the same collection in the past" do
    book(:grouping => :day).save
    collection = collections_for(book)[:past]

    first_entry = book.add_entry("hi1")
    second_entry = book.add_entry("hi2")

    assert collection.id != second_entry.collection_id
    assert first_entry.collection_id == second_entry.collection_id
  end

  test "adding an entry creates a collection in the past" do
    book(:grouping => :day).save
    entry = book.add_entry("hi1", Date.yesterday)
    assert_equal Date.yesterday, entry.collection.datetime
  end

  test "adding an entry creates a collection in the present" do
    book(:grouping => :day).save
    entry = book.add_entry("hi1", Date.today)
    assert_equal Date.today, entry.collection.datetime
  end

  test "adding an entry creates a collection in the future" do
    book(:grouping => :day).save
    entry = book.add_entry("hi1", Date.tomorrow)
    assert_equal Date.tomorrow, entry.collection.datetime
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

  test "a user cannot have to books with the same slug" do
    user = create(:user)
    create(:book, :user => user, :slug => "slug")
    assert_not build(:book, :user => user, :slug => "slug").valid?
  end

  test "two users can have to books with the same slug" do
    first_user = create(:user)
    second_user = create(:user)
    create(:book, :user => first_user, :slug => "slug")
    assert build(:book, :user => second_user, :slug => "slug").valid?
  end

  test "dirty flag when there are no entries" do
    book = create(:book)
    assert !book.dirty?
  end

  test "dirty flag when there are entries" do
    book = create(:book)
    create(:entry, :book => book)
    create(:extractor, :book => book)
    assert book.dirty?
  end

  test "dirty entries are correctly returned" do
    book = create(:book)
    dirty_entry = create(:entry, :processed_at => 1.minute.ago, :book => book)
    create(:extractor, :book => book)
    create(:entry, :processed_at => Time.now, :book => book)
    dirty_entries = book.dirty_entries
    assert dirty_entries.size == 1
    assert dirty_entries.first.id == dirty_entry.id
  end

private

  def book(overrides = {})
    @book ||= Book.new({ :user => create(:user),
                         :name => "Testing" }.merge(overrides))
  end

  def collections_for(book)
    {
      :past => create(:collection, :past, :book => book),
      :future => create(:collection, :future, :book => book),
      :present => create(:collection, :book => book)
    }
  end
end
