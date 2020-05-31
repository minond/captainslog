class VerticesController < ApplicationController
  def edit
    component VertexEditComponent, :vertex => current_vertex
  end

private

  param_reader :id
  param_reader :connection_id

  # @return [Vertex]
  def current_vertex
    Vertex.find_by(:id => id, :connection_id => connection_id)
  end
end
