class Book < ApplicationRecord
  belongs_to :user

  after_initialize :constructor

  enum :grouping => %i[none day], :_prefix => :group_by

  # @params [String] text
  # @params [Time] current_time, defaults to `Time.current`
  # @return [Entry]
  def add_entry(text, current_time = Time.current)
    Entry.create(:book => self,
                 :collection => collection_at(current_time, true),
                 :original_text => text)
  end

  # @param [Time] time
  # @param [Boolean] create_it
  # @return [Collection, Nil]
  def collection_at(time, create_it = false)
    start_time, end_time = time_range_at(time)

    res = Collection.by_book_id(id)
    res = start_time && end_time ? res.created_between(start_time, end_time) : res

    return res.first unless res.empty?
    return Collection.create(:book => self) if create_it
  end

private

  def constructor
    self.grouping ||= :none
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
