module Source::Client::Source
  extend extend ActiveSupport::Concern

  ID = Struct.new(:id, :keyword_init => true)

  included do
    traced :pull
  end

  class_methods do
    # @param [Array<Symbol>] sources
    def pulls_in(*sources)
      @available_sources = sources.map do |typ|
        ID.new(:id => typ)
      end

      sources.each do |ty|
        traced "pull_#{ty}"
      end
    end

    # @return [Array<Source::Client::Source::ID>]
    def available_sources
      @available_sources
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
    self.class.available_sources.each do |ty|
      send("pull_#{ty.id}", args, &block)
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
