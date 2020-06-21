class Service::Fitbit::HeartRate < Service::Record
  # @param [Hash] result
  # @return [HeartRate]
  def self.from_result(result)
    text = "Resting heart rate: #{result['value']['restingHeartRate']}"
    date = Date.parse(result["dateTime"])

    new(text, date)
  end

  # @param [Hash] result
  # @return [Boolean]
  def self.valid?(result)
    result.dig("value", "restingHeartRate").present?
  end

  # @return [String]
  def digest
    Base64.encode64("fitbit-resting-heart-rate-#{datetime}")
  end
end
