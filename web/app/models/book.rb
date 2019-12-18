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

private

  def constructor
    self.grouping ||= :none
  end

  # @return [Collection]
  def current_collection
    collection_at(Date.today)
  end

  # @param [Date] date
  # @return [Collection]
  def collection_at(date)
    start_time, end_time = time_range_at(date)

    query = Collection.by_book_id(id)
    query = query.created_between(start_time, end_time) if start_time && end_time
    query.first || Collection.create(:book => self)
  end

  # @param [Date] date
  # @return [Tuple<Date, Date>]
  def time_range_at(date)
    case
    when group_by_none? then []
    when group_by_day? then [date.beginning_of_day, date.end_of_day]
    else raise "invalid group"
    end
  end
end
