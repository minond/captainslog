class Source::Client
  include OpenTracing::Instrumented

  # @param [Symbol] source
  # @return [Class]
  def self.class_for_source(source)
    "Source::#{source.to_s.camelcase}".safe_constantize
  end

  # @param [Symbol] source
  # @param [String] auth_code
  # @return [Hash]
  def self.credentials_for_source(source, auth_code)
    client = class_for_source(source).new
    client.code = auth_code
    client.credential_options
  end

  # @param [Symbol] source
  # @param [Connection] connection, optional
  # @return [String]
  def self.auth_url_for_source(source, connection = nil)
    client = Source::Client.class_for_source(source).new
    client.auth_url(connection)
  end

  # @return [Symbol]
  def self.source
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

  # Path to page where user can start the authentication process for this
  # source.
  #
  # @param [Connection, nil] connection
  # @return [String]
  def auth_url(connection = nil)
    base_auth_url + "&state=#{self.class.encode_state(connection)}"
  end

  # Path to page where user can start the authentication process for this
  # source.
  #
  # @return [String]
  def base_auth_url
    raise NotImplementedError, "#base_auth_url is not implemented"
  end

  # @return [Hash]
  def credential_options
    raise NotImplementedError, "#credential_options is not implemented"
  end

  # @return [Boolean]
  def oauth?
    self.class < Oauth
  end

  # @return [Boolean]
  def input?
    self.class < Input
  end

  # @return [Boolean]
  def output?
    self.class < Output
  end

private

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
