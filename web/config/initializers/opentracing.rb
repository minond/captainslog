require "jaeger/client"

path = File.join(Rails.root, "config", "jaeger.yml")
yaml = ERB.new(File.read(path)).result
conf = YAML.safe_load(yaml)
Rails.application.config.jaeger = conf.with_indifferent_access

return if Rails.env.test?

OpenTracing.global_tracer = Tracing.build_tracer

Tracing::ActiveRecord.instrument!
