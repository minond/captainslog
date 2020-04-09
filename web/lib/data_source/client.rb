class DataSource::Client
  # @param [Symbol] data_source
  # @return [Class]
  def self.for_data_source(data_source)
    "DataSource::#{data_source.to_s.camelcase}".safe_constantize
  end

  # @return [Symbol]
  def self.data_source
    name.demodulize.underscore.to_sym
  end

  # @param [Connection, nil] connection
  # @return [String]
  def self.encode_state(connection = nil)
    state = {}
    state[:connection_id] = connection.id if connection
    Base64.urlsafe_encode64(state.to_json)
  end

  # @param [String] encode_state
  # @param [Tuple<Integer>]
  def self.decode_state(encode_state)
    decoded_state = Base64.urlsafe_decode64(encode_state)
    state = JSON.parse(decoded_state).with_indifferent_access
    [state[:connection_id]]
  end

  # Path to page where user can start the authentication process for this data source.
  #
  # @param [Connection, nil] connection
  # @return [String]
  def auth_url(connection = nil)
    base_auth_url + "&state=#{self.class.encode_state(connection)}"
  end

  # Path to page where user can start the authentication process for this data source.
  #
  # @return [String]
  def base_auth_url
    raise NotImplementedError, "#base_auth_url is not implemented"
  end

  # @return [Hash]
  def credential_options
    raise NotImplementedError, "#credential_options is not implemented"
  end

  # @yieldparam [ProtoEntry]
  # @return [Array<ProtoEntry>]
  def data_pull_backfill(&block)
    data_pull(:start_date => self.class::DATA_PULL_BACKFILL_PERIOD_START.ago.to_date,
              :end_date => self.class::DATA_PULL_BACKFILL_PERIOD_END.from_now.to_date,
              &block)
  end

  # @yieldparam [ProtoEntry]
  # @return [Array<ProtoEntry>]
  def data_pull_standard(&block)
    data_pull(:start_date => self.class::DATA_PULL_STANDARD_PERIOD_START.ago.to_date,
              :end_date => self.class::DATA_PULL_STANDARD_PERIOD_END.from_now.to_date,
              &block)
  end

private

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<ProtoEntry>]
  def data_pull(_args)
    raise NotImplementedError, "#data_pull is not implemented"
  end
end
