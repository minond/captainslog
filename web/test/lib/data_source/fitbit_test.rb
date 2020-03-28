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

  test "authentication url" do
    assert DataSource::Fitbit.new.auth_url
  end

  test "authentication url with state" do
    user = create(:user)
    book = create(:book, :user => user)
    connection = create(:connection, :user => user, :book => book)
    assert_includes DataSource::Fitbit.new.auth_url(connection), "&state="
  end

  test "sets user_id after getting a token" do
    client.code = "123"
    token = client.instance_variable_get(:@client).token
    assert token["user_id"]
    assert_equal token["user_id"], client.instance_variable_get(:@user_id)
  end

  test "credential options" do
    client.code = "123"
    options = client.credential_options
    assert options[:user_id]
    assert options[:access_token]
    assert options[:refresh_token]
    assert options[:expires_at]
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
    activity_results = [
      steps_result(2.days.ago, 1234),
      steps_result(3.days.ago, 1233),
      steps_result(4.days.ago, 1232),
    ]
    results = { :activity_results => activity_results }
    entries = client(:results => results).send(:data_pull)
    assert_equal 3, entries.size
  end

  test "ignore invalid step results" do
    activity_results = [{}, steps_result(3.days.ago, 4321), {}]
    results = { :activity_results => activity_results }
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

  test "unique digests" do
    activity_results = [steps_result(3.days.ago, 4321)]
    heart_rate_results = [heart_rate_result(3.days.ago, 81)]
    weight_results = [weight_result(3.days.ago, 152)]

    results = {
      :activity_results => activity_results,
      :heart_rate_results => heart_rate_results,
      :weight_results => weight_results,
    }

    entries = client(:results => results).send(:data_pull)
    digests = entries.map(&:digest).uniq
    assert_equal 3, digests.size
  end

  test "reused digests" do
    activity_results = [
      steps_result(3.days.ago, 4321),
      steps_result(3.days.ago, 4322),
    ]

    heart_rate_results = [
      heart_rate_result(3.days.ago, 81),
      heart_rate_result(3.days.ago, 82),
    ]

    weight_results = [
      weight_result(3.days.ago, 151, :log_id => "123"),
      weight_result(3.days.ago, 152, :log_id => "123"),
    ]

    results = {
      :activity_results => activity_results,
      :heart_rate_results => heart_rate_results,
      :weight_results => weight_results,
    }

    entries = client(:results => results).send(:data_pull)
    digests = entries.map(&:digest).uniq
    assert_equal 6, entries.size
    assert_equal 3, digests.size
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

  def weight_result(date, weight = nil, bmi = nil, log_id: SecureRandom.uuid)
    {
      "logId" => log_id,
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
