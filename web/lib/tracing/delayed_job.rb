class Tracing::DelayedJob < Delayed::Plugin
  callbacks do |lifecycle|
    lifecycle.around(:enqueue) do |job, &block|
      OpenTracing.start_active_span("Enqueue #{get_job_name(job)}", :tags => generate_enqueue_tags(job)) do |scope|
        inject(job, scope.span)
        block.call(job)
      end
    end

    lifecycle.around(:perform) do |_worker, job, &block|
      parent = extract(job)
      references = [OpenTracing::Reference.follows_from(parent)] if parent
      OpenTracing.start_active_span("Perform #{get_job_name(job)}", :tags => generate_perform_tags(job), :references => references) do
        block.call(job)
      end
    end
  end

  # @param [Delayed::Backend::ActiveRecord::Job] job
  # @param [OpenTracing::Span] span
  def self.inject(job, span)
    carrier = {}
    OpenTracing.global_tracer.inject(span.context, OpenTracing::FORMAT_TEXT_MAP, carrier)
    job.metadata = JSON.dump(carrier)
  end

  # @param [Delayed::Backend::ActiveRecord::Job] job
  # @return [OpenTracing::SpanContext, nil]
  def self.extract(job)
    return unless job.metadata

    carrier = JSON.parse(job.metadata)
    OpenTracing.global_tracer.extract(OpenTracing::FORMAT_TEXT_MAP, carrier)
  rescue JSON::ParserError
    nil
  end

  # @param [Delayed::Backend::ActiveRecord::Job] job
  # @return [String]
  def self.get_job_name(job)
    YAML.safe_load(job.handler, [ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper]).job_data["job_class"]
  rescue StandardError
    "UnknownJob"
  end

  # @param [Delayed::Backend::ActiveRecord::Job] job
  # @return [Hash]
  def self.generate_enqueue_tags(job)
    {
      :component => "Delayed::Job",
      :"span.kind" => "client",
      :"dj.queue" => job.queue || "default"
    }
  end

  # @param [Delayed::Backend::ActiveRecord::Job] job
  # @return [Hash]
  def self.generate_perform_tags(job)
    {
      :component => "Delayed::Job",
      :"span.kind" => "server",
      :"dj.id" => job.id,
      :"dj.queue" => job.queue || "default",
      :"dj.attempts" => job.attempts
    }
  end
end
