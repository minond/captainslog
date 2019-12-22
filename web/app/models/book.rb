class Book < ApplicationRecord
  belongs_to :user

  after_initialize :constructor

  enum :grouping => %i[none day], :_prefix => :group_by

  # @params [String] text
  # @params [Time] current_time, defaults to `Time.current`
  # @return [Entry]
  def add_entry(text, current_time = Time.current)
    collection = collection(current_time) || create_collection(current_time)
    Entry.create(:book => self,
                 :collection => collection,
                 :original_text => text)
  end

  # @param [Time] time, defaults to `Time.current`
  # @return [Collection, Nil]
  def collection(time = Time.current)
    start_time, end_time = grouping_time_range(time)

    res = Collection.by_book_id(id)
    res = start_time && end_time ? res.datetime_between(start_time, end_time) : res

    res.first
  end

  # @param [Time] datetime
  # @return [Collection]
  def create_collection(datetime)
    Collection.create(:book => self, :datetime => datetime)
  end

  # Calculates the times for the book collection that is before and after a
  # given time.
  #
  # @param [Time] time
  # @return [Array<Time>]
  def grouping_prev_next_times(time)
    time_unit = grouping_time_unit
    prev_time = (time - time_unit).beginning_of_day
    next_time = (time + time_unit).beginning_of_day
    [prev_time, next_time]
  end

private

  def constructor
    self.grouping ||= :none
  end

  # Calculates a book collection's start and end times for any given time.
  #
  # @param [Time] time
  # @return [Tuple<Time, Time>]
  def grouping_time_range(time)
    if group_by_none?
      []
    elsif group_by_day?
      [time.beginning_of_day, time.end_of_day]
    else
      raise "invalid group"
    end
  end

  # Generates a book collection's time unit used to move back and forth between
  # separate collections.
  #
  # @return [::ActiveSupport::Duration]
  def grouping_time_unit
    if group_by_none?
      0
    elsif group_by_day?
      1.day
    else
      raise "invalid group"
    end
  end
end
