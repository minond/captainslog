class Book < ApplicationRecord
  belongs_to :user

  after_initialize :constructor

  enum :grouping => %i[none day], :_prefix => :group_by

  # @params [String] text
  # @params [Time] current_time, defaults to `Time.current`
  # @return [Entry]
  def add_entry(text, current_time = Time.current)
    collection = collection_at(current_time) || create_collection
    Entry.create(:book => self,
                 :collection => collection,
                 :original_text => text)
  end

  # @param [Time] time
  # @return [Collection, Nil]
  def collection_at(time)
    start_time, end_time = time_range_at(time)

    res = Collection.by_book_id(id)
    res = start_time && end_time ? res.created_between(start_time, end_time) : res

    res.first
  end

  # @return [Collection]
  def create_collection
    Collection.create(:book => self)
  end

  # Use in the book/nav partial when deciding the the book should be
  # highlighted.
  #
  # @param [Book, Nil] current_book
  # @return [String]
  def ui_nav_class(current_book)
    id == current_book&.id ? "active" : ""
  end

private

  def constructor
    self.grouping ||= :none
  end

  # @param [Time] time
  # @return [Tuple<Time, Time>]
  def time_range_at(time)
    if group_by_none?
      []
    elsif group_by_day?
      [time.beginning_of_day, time.end_of_day]
    else
      raise "invalid group"
    end
  end
end
