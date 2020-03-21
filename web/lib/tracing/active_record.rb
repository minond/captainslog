module Tracing::ActiveRecord
  def self.instrument!
    ActiveSupport::Notifications.subscribe("sql.active_record", Subscriber.new)
  end

  class Subscriber
    def call(_event, start_time, end_time, _id, data)
      return if skippable?(data)

      build_and_finish_span(start_time, end_time, data)
    end

    def skippable?(data)
      return true if ::OpenTracing.active_span.nil?
      return true if data[:name] == "SCHEMA"
      return true if data[:name] == "CACHE"
      return true if data[:sql] == "SELECT version()"
    end

    def build_and_finish_span(start_time, end_time, data)
      span = ::OpenTracing.start_span(generate_operation_name(data),
                                      :start_time => start_time,
                                      :tags => generate_tags(data))
      span.finish(:end_time => end_time)
    end

    def generate_operation_name(data)
      name = if !data[:name].nil?
               data[:name]
             elsif data[:sql] == "BEGIN"
               "Begin Transaction"
             elsif data[:sql] == "COMMIT"
               "Commit Transaction"
             end

      name ? "SQL #{name}" : "SQL"
    end

    def generate_tags(data)
      {
        :component => "ActiveRecord",
        :"span.kind" => "client",
        :"db.type" => "sql",
        :"db.cached" => data.fetch(:cached, false),
      }
    end
  end
end
