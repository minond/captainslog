class Vertex < ApplicationRecord
  belongs_to :user
  belongs_to :connection
  has_many :incoming, :dependent => :destroy, :class_name => :Edge, :foreign_key => :target_id
  has_many :outgoing, :dependent => :destroy, :class_name => :Edge, :foreign_key => :source_id

  validates :connection, :urn, :presence => true

  # @return [Service::Resource]
  def resource
    Service::Resource.from_urn(urn)
  end

  # @param [Service::Resource] resource
  def resource=(resource)
    self.urn = resource.urn.to_s
  end

  # @return [URN]
  def to_urn
    URN.parse(urn)
  end
end
