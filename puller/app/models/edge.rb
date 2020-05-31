class Edge < ApplicationRecord
  belongs_to :user
  belongs_to :tail, :class_name => :Vertex, :primary_key => :id, :foreign_key => :tail_id
  belongs_to :head, :class_name => :Vertex, :primary_key => :id, :foreign_key => :head_id

  validates :tail, :head, :user, :presence => true

  # Create an edge between two vertices.
  #
  # @param [Vertex] vertex1
  # @param [Vertex] vertex2
  # @return [Edge]
  def self.create_between(vertex1, vertex2)
    head, tail = head_and_tail(vertex1, vertex2)
    create(:user => head.user,
           :head => head,
           :tail => tail)
  end

  # Given vertex1 and vertex2, this method figures out the direction of the
  # endpoints and creates the edge. If vertex1 is the target, then it
  # represents the head of the edge. Sources represent the tail.
  #
  # @param [Vertex] vertex1
  # @param [Vertex] vertex2
  # @return [Tuple<Vertex, Vertex>]
  def self.head_and_tail(vertex1, vertex2)
    if vertex1.connection.target?
      [vertex1, vertex2]
    else
      [vertex2, vertex1]
    end
  end
end
