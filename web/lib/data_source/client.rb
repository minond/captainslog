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
  def pull
    raise NotImplementedError, "#pull is not implemented"
  end
end
