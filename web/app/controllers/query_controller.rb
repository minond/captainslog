class QueryController < ApplicationController
  skip_before_action :verify_authenticity_token

  # === URL
  #   GET /execute
  #
  # === Sample request
  #   /execute?query=select...
  #
  def execute
    runner = Querier::Runner.new(current_user.id, query)
    render :json => runner.run
  end

private

  # @return [ActionController::Parameters]
  def query
    params.require(:query)
  end
end
