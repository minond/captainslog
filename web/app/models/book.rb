class Book < ApplicationRecord
  include Grouping

  belongs_to :user

  after_initialize :constructor

  validates :user, :presence => true
  validates :name, :presence => true
  validates :grouping, :presence => true

  enum :grouping => %i[none day], :_prefix => :group_by

  # @param [String] text
  # @param [Time] time, defaults to `Time.current`. Use a time in the user's
  #   timezone for best results.
  # @return [Entry]
  def add_entry(text, time = Time.current)
    collection = find_collection(time) || create_collection(time)
    Entry.create(:book => self,
                 :collection => collection,
                 :original_text => text)
  end

  # @param [Time] time, defaults to `Time.current`. Use a time in the user's
  #   timezone for best results.
  # @return [Collection, Nil]
  def find_collection(time = Time.current)
    start_time, end_time = grouping_time_range(time)
    res = Collection.by_book_id(id)
    res = start_time && end_time ? res.datetime_between(start_time, end_time) : res
    res.first
  end

  # @param [Time] time, defaults to `Time.current`. Use user's timezone for
  #   best results.
  # @return [Collection]
  def create_collection(time)
    Collection.create(:book => self, :datetime => time)
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
