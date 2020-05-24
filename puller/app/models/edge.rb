class Edge < ApplicationRecord
  belongs_to :user
  belongs_to :tail, :class_name => :Vertex, :primary_key => :id, :foreign_key => :tail_id
  belongs_to :head, :class_name => :Vertex, :primary_key => :id, :foreign_key => :head_id

  validates :tail, :head, :user, :presence => true
end
