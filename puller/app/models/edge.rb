class Edge < ApplicationRecord
  belongs_to :user
  belongs_to :source, :class_name => :Vertex, :primary_key => :id, :foreign_key => :source_id
  belongs_to :target, :class_name => :Vertex, :primary_key => :id, :foreign_key => :target_id

  validates :target, :source, :user, :presence => true

  # Create an edge between two vertices.
  #
  # @param [Vertex] vertex1
  # @param [Vertex] vertex2
  # @return [Edge]
  def self.create_between(vertex1, vertex2)
    target, source = target_and_source(vertex1, vertex2)
    create(:user => target.user,
           :target => target,
           :source => source)
  end

  # Given vertex1 and vertex2, this method figures out the direction of the
  # endpoints and creates the edge. If vertex1 is the target, then it
  # represents the target of the edge. Sources represent the source.
  #
  # @param [Vertex] vertex1
  # @param [Vertex] vertex2
  # @return [Tuple<Vertex, Vertex>]
  def self.target_and_source(vertex1, vertex2)
    if vertex1.connection.target?
      [vertex1, vertex2]
    else
      [vertex2, vertex1]
    end
  end
end
