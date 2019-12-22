class Book < ApplicationRecord
  belongs_to :user

  after_initialize :constructor

  enum :grouping => %i[none day], :_prefix => :group_by

  # @params [String] text
  # @params [Time] current_time
  # @return [Entry]
  def add_entry(text, current_time)
    Entry.create(:book => self,
                 :collection => collection_at(current_time, true),
                 :original_text => text)
  end

  # @return [Collection]
  def current_collection
    collection_at(Time.now.utc)
  end

private

  def constructor
    self.grouping ||= :none
  end

  # @param [Time] time
  # @return [Collection]
  def collection_at(time)
    start_time, end_time = time_range_at(time)

    query = Collection.by_book_id(id)
    query = start_time && end_time ? query.created_between(start_time, end_time) : query

    query.first || Collection.create(:book => self)
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
