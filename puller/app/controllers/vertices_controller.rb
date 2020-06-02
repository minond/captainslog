class VerticesController < ApplicationController
  # GET /connection/:connection_id/vertices/:id/edit
  def edit
    component Vertex::Edit, :vertex => current_vertex
  end

private

  param_reader :id
  param_reader :connection_id

  # @return [Vertex]
  def current_vertex
    Vertex.find_by(:id => id, :connection_id => connection_id)
  end
end
