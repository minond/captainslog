module Source::Input
  extend extend ActiveSupport::Concern

  class_methods do
    # @param [Array<Symbol>] types
    def pulls_in(*types)
      @@input_record_types = types
    end

    # @param [Range<ActiveSupport::Duration>] range
    def backfill_range(range)
      @@backfill_range = range
    end

    # @return [Date]
    def backfill_range_start_date
      @@backfill_range.first.ago.to_date
    end

    # @return [Date]
    def backfill_range_end_date
      @@backfill_range.last.from_now.to_date
    end

    # @param [Range<ActiveSupport::Duration>] range
    def standard_range(range)
      @@standard_range = range
    end

    # @return [Date]
    def standard_range_start_date
      @@standard_range.first.ago.to_date
    end

    # @return [Date]
    def standard_range_end_date
      @@standard_range.last.from_now.to_date
    end
  end

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<ProtoEntry>]
  def data_pull(_args)
    raise NotImplementedError, "#data_pull is not implemented"
  end

  # @yieldparam [ProtoEntry]
  # @return [Array<ProtoEntry>]
  def data_pull_backfill(&block)
    data_pull(:start_date => self.class.backfill_range_start_date,
              :end_date => self.class.backfill_range_end_date,
              &block)
  end

  # @yieldparam [ProtoEntry]
  # @return [Array<ProtoEntry>]
  def data_pull_standard(&block)
    data_pull(:start_date => self.class.standard_range_start_date,
              :end_date => self.class.standard_range_end_date,
              &block)
  end
end
