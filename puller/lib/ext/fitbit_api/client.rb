class FitbitAPI::Client
  def weight_log_period(start_date, end_date, opts = {})
    get("user/-/body/log/weight/date/#{format_date(start_date)}/#{format_date(end_date)}.json", opts)["weight"]
  end
end
