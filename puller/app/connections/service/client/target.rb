module Service::Client::Target
  extend extend ActiveSupport::Concern

  Resource = Struct.new(:id, :label, :keyword_init => true)

  # @param [Array<Service::Record>] records
  # @param [Resource] resource
  def push(_records, _resource)
    raise NotImplementedError, "#push is not implemented"
  end

  # @return [Array<Resource>]
  def available_targets
    raise NotImplementedError, "#available_targets is not implemented"
  end
end
