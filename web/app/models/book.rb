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
    start_time, end_time = grouping_range_at(time)

    res = Collection.by_book_id(id)
    res = start_time && end_time ? res.datetime_between(start_time, end_time) : res

    res.first
  end

  # @param [Time] datetime
  # @return [Collection]
  def create_collection(datetime)
    Collection.create(:book => self, :datetime => datetime)
  end

  # The time in which the previous collection falls in relative to the provided
  # time
  #
  # @param [Time] time
  # @return [Time]
  def prev_collection_time(time)
    time - grouping_time_unit
  end

  # The time in which the previous collection falls in relative to the provided
  # time
  #
  # @param [Time] time
  # @return [Time]
  def next_collection_time(time)
    time + grouping_time_unit
  end

private

  def constructor
    self.grouping ||= :none
  end

  # @param [Time] time
  # @return [Tuple<Time, Time>]
  def grouping_range_at(time)
    if group_by_none?
      []
    elsif group_by_day?
      [time.beginning_of_day, time.end_of_day]
    else
      raise "invalid group"
    end
  end

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
