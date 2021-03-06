class Service::Fitbit::Steps < Service::Record
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
    Base64.urlsafe_encode64("fitbit-steps-#{datetime}")
  end
end
