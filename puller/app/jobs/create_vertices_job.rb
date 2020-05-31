class CreateVerticesJob < ApplicationJob
  queue_as :default

  # @param [Integer] id
  def perform(id)
    connection = Connection.find(id)
    connection.create_vertices!
    connection.touch
  end
end
