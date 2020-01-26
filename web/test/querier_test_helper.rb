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
end
