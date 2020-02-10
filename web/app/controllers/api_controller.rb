class ApiController < ActionController::API
private

  # JSON rendering helper method
  #
  # @param [Hash] response
  # @param [hash] options
  def json(response, options = {})
    render options.merge(:json => response)
  end
end
