require "test_helper"

class GroupingTest < ActiveSupport::TestCase
  setup { travel_to "2019-05-21 14:32:53" }

  test "grouping time ranges for all groups" do
    assert_grouping_time_ranges Book.new(:grouping => :none), nil, nil
    assert_grouping_time_ranges Book.new(:grouping => :day), Time.now.beginning_of_day.utc, Time.now.end_of_day.utc
    assert_grouping_time_ranges Book.new(:grouping => :week), Time.now.beginning_of_week.utc, Time.now.end_of_week.utc
    assert_grouping_time_ranges Book.new(:grouping => :month), Time.now.beginning_of_month.utc, Time.now.end_of_month.utc
    assert_grouping_time_ranges Book.new(:grouping => :year), Time.now.beginning_of_year.utc, Time.now.end_of_year.utc
  end

  test "grouping time units for all groups" do
    assert_grouping_time_unit Book.new(:grouping => :none), 0
    assert_grouping_time_unit Book.new(:grouping => :day), 1.day
    assert_grouping_time_unit Book.new(:grouping => :week), 1.week
    assert_grouping_time_unit Book.new(:grouping => :month), 1.month
    assert_grouping_time_unit Book.new(:grouping => :year), 1.year
  end

private

  # @param [Book] book
  # @param [ActiveSupport::Duration]
  def assert_grouping_time_unit(book, expected_time_unit)
    assert_equal book.send(:grouping_time_unit), expected_time_unit
  end

  # @param [Book] book
  # @param [Time, nil] expected_start_time
  # @param [Time, nil] expected_end_time
  #
  # rubocop:disable Metrics/MethodLength
  def assert_grouping_time_ranges(book, expected_start_time, expected_end_time)
    start_time, end_time = book.send(:grouping_time_range, Time.now)

    if expected_start_time.nil?
      assert_nil start_time
    else
      assert_equal expected_start_time, start_time
    end

    if expected_end_time.nil?
      assert_nil end_time
    else
      assert_equal expected_end_time, end_time
    end
  end
  # rubocop:enable Metrics/MethodLength
end
