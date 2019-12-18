class Book < ApplicationRecord
  belongs_to :user

  after_initialize :constructor

  enum :grouping => [:none, :day], :_prefix => :group_by

  # @params [String] text
  # @return [Entry]
  def add_entry(text)
    Entry.create(:book => self,
                 :collection => current_collection,
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
    query = Collection.by_book_id(id)
    start_time, end_time = time_range_at(time)

    if start_time && end_time
      query = query.created_between(start_time, end_time)
    end

    query.first || Collection.create(:book => self)
  end

  # @param [Time] time
  # @return [Tuple<Time, Time>]
  def time_range_at(time)
    case
    when group_by_none? then []
    when group_by_day? then [time.beginning_of_day, time.end_of_day]
    else raise "invalid group"
    end
  end
end
