class Service::Resource
  attr_reader :id, :service, :label

  # @param [String] urn
  # @return [Resource]
  def self.from_urn(urn)
    _urn, service, id = urn.split(":")
    new(id, service)
  end

  # @param [String] id
  # @param [Symbol] service
  # @param [String] label
  def initialize(id, service, label = "")
    @id = id
    @service = service
    @label = label
  end

  # @return [String]
  def urn
    "urn:#{service}:#{id}"
  end

  def label
    @label.presence || id.to_s.humanize
  end
end
