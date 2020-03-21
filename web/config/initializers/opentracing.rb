require "jaeger/client"

path = File.join(Rails.root, "config", "jaeger.yml")
yaml = ERB.new(File.read(path)).result
conf = YAML.safe_load(yaml)
Rails.application.config.jaeger = conf.with_indifferent_access

return if Rails.env.test?

service_name = ARGV.first == "jobs:work" ? "worker" : "web"

OpenTracing.global_tracer = Jaeger::Client.build(
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
