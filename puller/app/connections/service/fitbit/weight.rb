class Service::Fitbit::Weight < Service::Record
  # @param [Hash] result
  # @return [Weight]
  def self.from_result(result)
    text = text_from_result(result)
    date = Date.parse("#{result['date']} #{result['time']}")
    log_id = result["logId"]

    new(text, date, log_id)
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
  # @param [Date] date
  # @param [String] log_id
  def initialize(text, date, log_id)
    super(text, date)
    @log_id = log_id
  end

  # @return [String]
  def digest
    Base64.encode64("fitbit-weight-#{@log_id}")
  end
end
