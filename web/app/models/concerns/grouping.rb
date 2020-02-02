# Grouping helpers for books and their collections. Used to find and create
# current, past, and upcoming collections for any given book and group setting.
module Grouping
private

  # Calculates a book collection's start and end times for any given time.
  #
  # @param [Time] time
  # @return [Tuple<Time, Time>]
  #
  # rubocop:disable Metrics/AbcSize
  def grouping_time_range(time)
    case grouping.to_sym
    when :none then []
    when :day then [time.beginning_of_day.utc, time.end_of_day.utc]
    when :week then [time.beginning_of_week.utc, time.end_of_week.utc]
    when :month then [time.beginning_of_month.utc, time.end_of_month.utc]
    when :year then [time.beginning_of_year.utc, time.end_of_year.utc]
    end
  end
  # rubocop:enable Metrics/AbcSize

  # Generates a book collection's time unit used to move back and forth between
  # separate collections.
  #
  # @return [::ActiveSupport::Duration]
  def grouping_time_unit
    case grouping.to_sym
    when :none then 0
    when :day then 1.day
    when :week then 1.week
    when :month then 1.month
    when :year then 1.year
    end
  end

  # Calculates the times for the book collection that is before and after a
  # given time.
  #
  # @param [Time] time
  # @return [Array<Time>]
  def grouping_prev_next_times(time)
    time_unit = grouping_time_unit
    prev_time = time - time_unit
    next_time = time + time_unit
    [prev_time, next_time]
  end
end
