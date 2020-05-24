module Source::Client::Output
  extend extend ActiveSupport::Concern

  Destination = Struct.new(:id, :label, :keyword_init => true)

  # @param [Array<Source::Record>] records
  # @param [Destination] destination
  def push(records, destination)
    raise NotImplementedError, "#push is not implemented"
  end

  # @return [Array<Destination>]
  def available_output_destinations
    raise NotImplementedError, "#available_output_destinations is not implemented"
  end
end
