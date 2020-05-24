class Vertex < ApplicationRecord
  belongs_to :user
  belongs_to :connection
  has_many :incoming, :dependent => :destroy, :class_name => :Edge, :foreign_key => :head_id
  has_many :outgoing, :dependent => :destroy, :class_name => :Edge, :foreign_key => :tail_id

  validates :connection, :urn, :presence => true

  # @return [Service::Client::Target::Resource, Service::Client::Source::Resource]
  def resource
    _urn, direction, _service, id = urn.split(":")
    Service.resource_class_for_direction(direction).new(:id => id)
  end

  # @param [Service::Client::Target::Resource, Service::Client::Source::Resource] resource
  def resource=(resource)
    id = resource.id
    direction = connection.source? ? "source" : "target"
    service = connection.service
    self.urn = "urn:#{direction}:#{service}:#{id}"
  end
end
