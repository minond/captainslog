module QuerierTestHelper
  # @param [String] text, defaults to an empty string
  # @param [Hash] data, defaults to an empty hash
  # @return [ExternalServiceTestHelper::HTTPResponse]
  def self.new_ok_response(columns, results)
    response = {
      :data => {
        :columns => columns,
        :results => results
      }
    }

    ExternalServiceTestHelper::HTTPResponse.new("200", response.to_json)
  end

  # @param [ExternalServiceTestHelper::HTTPResponse] http_res
  # @return [Querier::Runner]
  def self.new_runner_with_response(http_res)
    poster = ExternalServiceTestHelper::Poster.new(http_res)
    client = Querier::Client.new(poster)
    Querier::Runner.new(23, "select 1", client)
  end

  # Creates a sample successful test http response and returns it along with
  # the columns and results.
  #
  # @return [Tuple<ExternalServiceTestHelper::HTTPResponse, Array<String>, Array<Array<Hash>>>]
  def self.new_sample_response
    columns = ["col1", "col2", "col3"]
    results = [[[], [], []], [[], [], []]]
    response = new_ok_response(columns, results)
    [response, columns, results]
  end
end
