class Service::Fitbit::Weight < Service::Record
  # @param [Hash] result
  # @return [Weight]
  def self.from_result(result)
    text = text_from_result(result)
    datetime = Date.parse("#{result['date']} #{result['time']}")
    log_id = result["logId"]

    new(text, datetime, log_id)
  end

  # @param [Hash] result
  # @return [String]
  def self.text_from_result(result)
    weight = result["weight"]
    weight_text = "Weight: #{weight}" if weight

    bmi = result["bmi"]
    bmi_text = "BMI: #{bmi}" if bmi

    [weight_text, bmi_text].join(" ")
  end

  # @param [Hash] result
  # @return [Boolean]
  def self.valid?(result)
    result["logId"] && (result["weight"] || result["bmi"])
  end

  # @param [String] text
  # @param [DateTime] datetime
  # @param [String] log_id
  def initialize(text, datetime, log_id)
    super(text, datetime)
    @log_id = log_id
  end

  # @return [String]
  def digest
    Base64.urlsafe_encode64("fitbit-weight-#{@log_id}")
  end
end
