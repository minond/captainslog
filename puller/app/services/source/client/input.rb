module Source::Client::Input
  extend extend ActiveSupport::Concern

  included do
    traced :pull
  end

  class_methods do
    # @param [Array<Symbol>] types
    def pulls_in(*types)
      @available_input_types = types
      types.each do |ty|
        traced "pull_#{ty}"
      end
    end

    # @return [Array<Symbol>]
    def available_input_types
      @available_input_types
    end

    # @param [Range<ActiveSupport::Duration>] range
    def backfill_range(range)
      @backfill_range = range
    end

    # @return [Date]
    def backfill_range_start_date
      @backfill_range.first.ago.to_date
    end

    # @return [Date]
    def backfill_range_end_date
      @backfill_range.last.from_now.to_date
    end

    # @param [Range<ActiveSupport::Duration>] range
    def standard_range(range)
      @standard_range = range
    end

    # @return [Date]
    def standard_range_start_date
      @standard_range.first.ago.to_date
    end

    # @return [Date]
    def standard_range_end_date
      @standard_range.last.from_now.to_date
    end
  end

  # @yieldparam [Source::Record]
  def pull(**args, &block)
    self.class.available_input_types.each do |ty|
      send("pull_#{ty}", args, &block)
    end
  end

  # @yieldparam [Source::Record]
  def pull_backfill(&block)
    pull(:start_date => self.class.backfill_range_start_date,
         :end_date => self.class.backfill_range_end_date,
         &block)
  end

  # @yieldparam [Source::Record]
  def pull_standard(&block)
    pull(:start_date => self.class.standard_range_start_date,
         :end_date => self.class.standard_range_end_date,
         &block)
  end
end
