class Book < ApplicationRecord
  belongs_to :user

  after_initialize :constructor

  enum :grouping => %i[none day], :_prefix => :group_by

  # @params [String] text
  # @params [Time] time, defaults to `Time.current`. Use a time in the user's
  #   timezone for best results.
  # @return [Entry]
  def add_entry(text, time = Time.current)
    collection = collection(time) || create_collection(time)
    Entry.create(:book => self,
                 :collection => collection,
                 :original_text => text)
  end

  # @params [Time] time, defaults to `Time.current`. Use a time in the user's
  #   timezone for best results.
  # @return [Collection, Nil]
  def collection(time = Time.current)
    start_time, end_time = grouping_time_range(time)

    res = Collection.by_book_id(id)
    res = start_time && end_time ? res.datetime_between(start_time, end_time) : res

    res.first
  end

  # @params [Time] time, defaults to `Time.current`. Use user's timezone for
  #   best results.
  # @return [Collection]
  def create_collection(time)
    Collection.create(:book => self, :datetime => time.utc)
  end

  # Calculates the times for the book collection that is before and after a
  # given time.
  #
  # @params [Time] time, defaults to `Time.current`. Use user's timezone for
  #   best results.
  # @return [Array<Time>]
  def grouping_prev_next_times(time)
    time_unit = grouping_time_unit
    prev_time = time - time_unit
    next_time = time + time_unit
    [prev_time, next_time]
  end

private

  def constructor
    self.grouping ||= :none
  end

  # Calculates a book collection's start and end times for any given time.
  #
  # @params [Time] time, defaults to `Time.current`. Use user's timezone for
  #   best results.
  # @return [Tuple<Time, Time>]
  def grouping_time_range(time)
    if group_by_none?
      []
    elsif group_by_day?
      [time.beginning_of_day.utc, time.end_of_day.utc]
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
