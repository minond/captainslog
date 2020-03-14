require "test_helper"

class DataSourceFibitTest < ActiveSupport::TestCase
  setup do
  end

  test "standard data pull with no results" do
    client.data_pull_standard
  end

  test "backfill data pull with no results" do
    client.data_pull_backfill
  end

private

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
