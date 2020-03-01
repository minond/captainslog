class DataSource::Fitbit::Steps < ProtoEntry
  # @param [Hash] result
  # @return [Steps]
  def self.from_result(result)
    text = "Steps: #{result['value']}"
    date = Date.parse(result["dateTime"])

    new(text, date)
  end

  # @param [Hash] result
  # @return [Boolean]
  def self.valid?(result)
    result["value"] && result["value"] != "0"
  end

  # @return [String]
  def digest
    Base64.encode64("fitbit-steps-#{date}")
  end
end
