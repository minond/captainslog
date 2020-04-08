module Iter
  # Takes while results of yielding are not nil. Passing a counter each time
  # the block is executed. Returns array containing every result of yielding,
  # excluding the last `nil` value.
  #
  # @yieldparam [Integer] i
  # @yieldreturn [Object]
  # @return [Array<Object>]
  def take_while_with_index
    i = 0
    buff = []

    loop do
      res = yield i
      break unless res.present?

      buff << res
      i += 1
    end

    buff
  end

  # Helper method for iterating over date ranges with a step.
  #
  # @param [Date] start_date
  # @param [Date] end_date
  # @param [ActiveSupport::Duration] step
  # @yieldparam [Date] sub_start_date
  # @yieldparam [Date] sub_end_date
  # @yieldreturn [Object]
  # @return [Array<Object>]
  def map_over_date_range(start_date, end_date, step)
    results = []

    (start_date.to_datetime.to_i..end_date.to_datetime.to_i).step(step).each do |sub_start_timestamp|
      sub_start_date = Time.at(sub_start_timestamp)
      sub_end_date = sub_start_date + step
      sub_end_date = end_date.to_datetime if sub_end_date > end_date
      results += yield(sub_start_date, sub_end_date)
    end

    results
  end
end
