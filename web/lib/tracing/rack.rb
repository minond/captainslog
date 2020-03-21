# frozen_string_literal: true

class Tracing::Rack
  def initialize(app)
    @app = app
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def call(env)
    method = env["REQUEST_METHOD"]

    tags = {
      :component => "rack",
      :"span.kind" => "server",
      :"http.method" => method,
      :"http.url" => env["REQUEST_URI"]
    }

    scope = OpenTracing.global_tracer.start_active_span(method, :tags => tags)
    span = scope.span
    env["rack.span"] = span

    @app.call(env).tap do |status_code, _headers, _body|
      span.set_tag("http.status_code", status_code)
      rails_controller = env["action_controller.instance"]
      route = "#{env['REQUEST_METHOD']} #{rails_controller.controller_name.camelcase}.#{rails_controller.action_name}" if rails_controller
      span.operation_name = route if route
    end
  rescue StandardError => e
    span.set_tag("error", true)
    span.log_kv(:event => "error",
                :"error.kind" => e.class.to_s,
                :"error.object" => e,
                :message => e.message,
                :stack => e.backtrace.join("\n"))

    raise
  ensure
    scope.close
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
