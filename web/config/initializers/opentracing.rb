require "jaeger/client"

require "opentracing/tracers/active_record"
require "opentracing/tracers/delayed_job"

path = File.join(Rails.root, "config", "jaeger.yml")
yaml = ERB.new(File.read(path)).result
conf = YAML.safe_load(yaml)
Rails.application.config.jaeger = conf.with_indifferent_access

return if Rails.env.test?

service_name = ARGV.first == "jobs:work" ? "web-worker" : "web-web"
OpenTracing.global_tracer = OpenTracing::Tracers.build_jaeger_client(service_name)

OpenTracing::Tracers::ActiveRecord.instrument! unless ARGV.first == "jobs:work"
OpenTracing::Tracers::DelayedJob.instrument!
