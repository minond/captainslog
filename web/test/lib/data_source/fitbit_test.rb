require "test_helper"

class DataSourceFibitTest < ActiveSupport::TestCase
  test "data source" do
    assert_equal :fitbit, DataSource::Fitbit.data_source
  end

  test "standard data pull with no results" do
    client.data_pull_standard
  end

  test "backfill data pull with no results" do
    client.data_pull_backfill
  end

  test "parse valid heart rate results" do
    heart_rate_results = [
      heart_rate_result(2.days.ago, 80),
      heart_rate_result(3.days.ago, 81),
      heart_rate_result(4.days.ago, 82),
    ]
    results = { :heart_rate_results => heart_rate_results }
    entries = client(:results => results).send(:data_pull)
    assert_equal 3, entries.size
  end

  test "ignore invalid heart rate results" do
    heart_rate_results = [{}, heart_rate_result(3.days.ago, 81), {}]
    results = { :heart_rate_results => heart_rate_results }
    entries = client(:results => results).send(:data_pull)
    assert_equal 1, entries.size
  end

  test "parse valid step results" do
    steps_results = [
      steps_result(2.days.ago, 1234),
      steps_result(3.days.ago, 1233),
      steps_result(4.days.ago, 1232),
    ]
    results = { :activity_results => steps_results }
    entries = client(:results => results).send(:data_pull)
    assert_equal 3, entries.size
  end

  test "ignore invalid step results" do
    steps_results = [{}, steps_result(3.days.ago, 4321), {}]
    results = { :activity_results => steps_results }
    entries = client(:results => results).send(:data_pull)
    assert_equal 1, entries.size
  end

  test "parse valid weight results" do
    weight_results = [
      weight_result(2.days.ago, 151),
      weight_result(3.days.ago, 152),
      weight_result(4.days.ago, 153),
    ]
    results = { :weight_results => weight_results }
    entries = client(:results => results).send(:data_pull)
    assert_equal 3, entries.size
  end

  test "ignore invalid weight results" do
    weight_results = [{}, weight_result(3.days.ago, 152), {}]
    results = { :weight_results => weight_results }
    entries = client(:results => results).send(:data_pull)
    assert_equal 1, entries.size
  end

private

  def heart_rate_result(date, value)
    {
      "dateTime" => date.to_s,
      "value" => {
        "restingHeartRate" => value,
      }
    }
  end

  def steps_result(date, value)
    {
      "dateTime" => date.to_s,
      "value" => value,
    }
  end

  def weight_result(date, weight = nil, bmi = nil)
    {
      "logId" => SecureRandom.uuid,
      "date" => date.to_date.to_s,
      "time" => date.to_time.to_s.split.second,
      "weight" => weight,
      "bmi" => bmi,
    }
  end

  def client(options: {}, results: {})
    @client ||=
      begin
        client = DataSource::Fitbit.new(options)
        client.instance_variable_set(:@client, fake_fitbit_api_client(results))
        client
      end
  end

  def fake_fitbit_api_client(results = {})
    FakeFitbitAPIClient.new(**results)
  end
end
