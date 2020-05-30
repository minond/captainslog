module Broadcaster
  extend ActiveSupport::Concern

  included do
    define_broadcast_method name
  end

  class_methods do
    def belongs_to(*args)
      define_broadcast_method args.first, true
      super
    end

    # Defines a broadcast_user_X method
    #
    # @example
    #
    #   def broadcast_user_job
    #     ActionCable.server.broadcast("user/42/jobs", id)
    #   end
    #
    #   def broadcast_user_connection
    #     ActionCable.server.broadcast("user/42/connections", send(:connection).id)
    #   end
    #
    #
    # @param [Symbol] name
    # @param [Boolean] external, defaults to false. Used to retrieve the record
    #   id from the right source.
    def define_broadcast_method(name, external = false)
      define_method "broadcast_user_#{name.to_s.underscore}" do
        record_id = external ? send(name).id : id
        stream_name = "user/#{user.id}/#{name.to_s.pluralize.underscore}"
        ActionCable.server.broadcast(stream_name, record_id)
      end
    end
  end
end
