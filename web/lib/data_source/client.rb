class DataSource::Client
  FREQUENCIES = %i[daily].freeze

  class << self
    attr_reader :frequency
  end

  # @param [Symbol] data_source
  # @return [Class]
  def self.for_data_source(data_source)
    "DataSource::#{data_source.to_s.camelcase}".safe_constantize
  end

  # @return [Symbol]
  def self.data_source
    name.demodulize.underscore.to_sym
  end

  # @param [Symbol]
  # @raise [ArgumentError] when an invalid frequency is passed
  def self.frequency!(frequency)
    message = "#{frequency} is not a valid frequency, must be one of: #{FREQUENCIES.join(', ')}"
    raise ArgumentError, message unless FREQUENCIES.include?(frequency)

    @frequency = frequency
  end

  # Path to page where user can start the authentication process for this data source.
  #
  # @return [String]
  def auth_url
    raise NotImplementedError, "#auth_url is not implemented"
  end

  # @return [Hash]
  def credential_options
    raise NotImplementedError, "#credential_options is not implemented"
  end

  # @return [Array<ProtoEntry>]
  def data_pull_backfill
    data_pull(:start_date => self.class::DATA_PULL_BACKFILL_PERIOD_START.ago.to_date,
              :end_date => self.class::DATA_PULL_BACKFILL_PERIOD_END.from_now.to_date)
  end

  # @return [Array<ProtoEntry>]
  def data_pull_standard
    data_pull(:start_date => self.class::DATA_PULL_STANDARD_PERIOD_START.ago.to_date,
              :end_date => self.class::DATA_PULL_STANDARD_PERIOD_END.from_now.to_date)
  end

private

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<ProtoEntry>]
  def data_pull(_args)
    raise NotImplementedError, "#data_pull is not implemented"
  end
end
