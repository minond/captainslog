module Service::Client::Target
  extend extend ActiveSupport::Concern

  # @param [Array<Service::Record>] records
  # @param [Service::Resource] resource
  def push(_records, _resource)
    raise NotImplementedError, "#push is not implemented"
  end

  # @return [Array<Service::Resource>]
  def available_targets
    raise NotImplementedError, "#available_targets is not implemented"
  end
end
