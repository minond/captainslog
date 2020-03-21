module Tracing
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.build_tracer
    service_name = ARGV.first == "jobs:work" ? "worker" : "web"
    Jaeger::Client.build(
      :host => Rails.application.config.jaeger[:host],
      :port => Rails.application.config.jaeger[:port],
      :service_name => service_name,
      :sampler => Jaeger::Samplers::Const.new(true),
      :reporter => Jaeger::Client::Reporters::RemoteReporter.new(
        :flush_interval => Rails.application.config.jaeger[:flush_interval],
        :sender => Jaeger::UdpSender.new(
          :host => Rails.application.config.jaeger[:host],
          :port => Rails.application.config.jaeger[:port],
          :max_packet_size => Rails.application.config.jaeger[:max_packet_size],
          :logger => Logger.new(STDOUT),
          :encoder => Jaeger::Encoders::ThriftEncoder.new(
            :service_name => service_name
          )
        )
      )
    )
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
