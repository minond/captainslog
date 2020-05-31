class EdgesController < ApplicationController
  # POST /connection/:connection_id/vertices/:vertex_id/edges
  def create
    message = create_edge.errors.empty? ? t(:ok) : t(:not_ok)
    redirect_to edit_connection_vertex_path(current_connection, current_vertex),
                :notice => message
  end

  # DELETE /connection/:connection_id/vertices/:vertex_id/edges/:id
  def destroy
    current_edge.destroy!
    redirect_to edit_connection_vertex_path(current_connection, current_vertex),
                :notice => t(:ok)
  end

private

  param_reader :id
  param_reader :vertex_id
  param_reader :head_or_tail_vertex_id

  # @return [Edge]
  def create_edge
    Edge.create_between(current_vertex, selected_vertex)
  end

  # @return [Connection]
  def current_connection
    @current_connection ||= current_vertex.connection
  end

  # @return [Edge]
  def current_edge
    @current_edge ||= Edge.find_by(:id => id, :user => current_user)
  end

  # @return [Vertex]
  def current_vertex
    @current_vertex ||= Vertex.find_by(:id => vertex_id, :user => current_user)
  end

  # @return [Vertex]
  def selected_vertex
    @selected_vertex ||= Vertex.find_by(:id => head_or_tail_vertex_id, :user => current_user)
  end
end
