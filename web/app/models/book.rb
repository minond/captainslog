class Book < ApplicationRecord
  include Grouping

  belongs_to :user

  after_initialize :constructor

  enum :grouping => %i[none day], :_prefix => :group_by

  # @params [String] text
  # @params [Time] time, defaults to `Time.current`. Use a time in the user's
  #   timezone for best results.
  # @return [Entry]
  def add_entry(text, time = Time.current)
    collection = find_collection(time) || create_collection(time)
    Entry.create(:book => self,
                 :collection => collection,
                 :original_text => text)
  end

  # @params [Time] time, defaults to `Time.current`. Use a time in the user's
  #   timezone for best results.
  # @return [Collection, Nil]
  def find_collection(time = Time.current)
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

  # @see `Grouping.grouping_prev_next_times`
  def grouping_prev_next_times(time)
    super
  end

private

  def constructor
    self.grouping ||= :none
  end
end
