module Source::Client::Output
  extend extend ActiveSupport::Concern

  Destination = Struct.new(:id, :label, :keyword_init => true)

  # @return [Array<Target>]
  def available_output_destinations
    raise NotImplementedError, "#available_output_destinations is not implemented"
  end
end
