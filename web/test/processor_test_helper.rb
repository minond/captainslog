module ProcessorTestHelper
  class Runner
    def run(_entry)
      ["updated text", { :a => :b }]
    end
  end

  # @param [String] text, defaults to an empty string
  # @param [Hash] data, defaults to an empty hash
  # @return [ExternalServiceTestHelper::HTTPResponse]
  def self.new_ok_response(text = "", data = {})
    response = {
      :data => {
        :text => text,
        :data => data
      }
    }

    ExternalServiceTestHelper::HTTPResponse.new("200", response.to_json)
  end

  # @param [ExternalServiceTestHelper::HTTPResponse] http_res
  # @return [Processor::Runner]
  def self.new_runner_with_response(http_res)
    poster = ExternalServiceTestHelper::Poster.new(http_res)
    client = Processor::Client.new(poster)
    Processor::Runner.new(FactoryBot.create(:entry), client)
  end

  # Creates a sample successful test http response and returns this along with
  # the used text and data.
  #
  # @return [Tuple<ExternalServiceTestHelper::HTTPResponse, String, Hash>]
  def self.new_sample_response
    expected_text = "hi"
    expected_data = { "a" => "b" }
    response = new_ok_response(expected_text, expected_data)
    [response, expected_text, expected_data]
  end
end
