class Service::Resource
  attr_reader :id, :service

  # @param [String] str
  # @return [Resource]
  def self.from_urn(str)
    urn = URN.parse(str)
    new(urn.nss, urn.nid, urn.q[:label])
  end

  # @param [String] id
  # @param [Symbol] service
  # @param [String] label
  def initialize(id, service, label = "")
    @id = id
    @service = service
    @label = label
  end

  # @return [URN]
  def urn
    URN.new(service, id, :q => { :label => @label })
  end

  def label
    @label.presence || id.to_s.humanize
  end
end
