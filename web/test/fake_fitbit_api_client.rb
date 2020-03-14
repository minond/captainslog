class FakeFitbitAPIClient
  def initialize(results = {})
    @heart_rate_results = results[:heart_rate_results] || []
    @activity_results = results[:activity_results] || []
    @weight_results = results[:weight_results] || []
  end

  def heart_rate_time_series(_options)
    heart_rate_results
  end

  def activity_time_series(_activity, _options)
    activity_results
  end

  def weight_log_period(_start_date, _end_date)
    weight_results
  end

private

  attr_reader :heart_rate_results
  attr_reader :activity_results
  attr_reader :weight_results
end
