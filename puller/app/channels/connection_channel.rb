class ConnectionChannel < ApplicationCable::Channel
  def subscribed
    stream_index_updates(:connection)
  end
end
