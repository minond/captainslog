module Service::Client::Source
  extend extend ActiveSupport::Concern

  included do
    traced :pull
  end

  class_methods do
    # @param [Array<Symbol>] sources
    def pulls_in(*sources)
      @available_source_resources = sources.map do |typ|
        Service::Resource.new(typ, service)
      end

      sources.each do |ty|
        traced "pull_#{ty}"
      end
    end

    # @return [Array<Service::Resource>]
    def available_source_resources
      @available_source_resources
    end

    # @param [Array<Symbol>] resources
    # @return [Array<Service::Resource>]
    def selected_source_resources(selected_resources)
      available_source_resources.select do |ty|
        selected_resources.include?(ty.id)
      end
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

    # @return [Hash]
    def backfill_range_dates
      {
        :start_date => backfill_range_start_date,
        :end_date => backfill_range_end_date,
      }
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

    # @return [Hash]
    def standard_range_dates
      {
        :start_date => standard_range_start_date,
        :end_date => standard_range_end_date,
      }
    end
  end

  # @param [Hash] options
  # @option [Date] start_date
  # @option [Date] end_date
  # @option [Array<Symbol>] resources
  # @yieldparam [Service::Record]
  def pull(**options, &block)
    resources = options.delete(:resources)&.map(&:to_sym) || []
    self.class.selected_source_resources(resources).each do |ty|
      send("pull_#{ty.id}", options, &block)
    end
  end

  # @param [Hash] options
  # @option [Array<Symbol>] resources
  # @yieldparam [Service::Record]
  def pull_backfill(**options, &block)
    pull(options.merge(self.class.backfill_range_dates), &block)
  end

  # @param [Hash] options
  # @option [Array<Symbol>] resources
  # @yieldparam [Service::Record]
  def pull_standard(**options, &block)
    pull(options.merge(self.class.standard_range_dates), &block)
  end
end
