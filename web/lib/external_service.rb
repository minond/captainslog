module ExternalService
  # Error is the top-level class for all external service errors.
  Error = Class.new(StandardError)

  # Dynamically generate a client class for an external service
  #
  # @example
  #   module Service
  #     Client = ExternalService.client(Processor::Response,
  #                                     Processor::RequestError,
  #                                     Rails.application.config.processor)
  #   end
  #
  # @param [Class] response_class
  # @param [Class] error_class
  # @param [Hash] default_config
  # @return [Class]
  #
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.client(label:, response_class:, error_class:, default_config: {})
    Class.new do
      # @param [HTTPPostClient] poster, defaults to `Net::HTTP`. This should be
      #   anything that responds to `post` with a uri and request body. This is
      #   what we'll be using ot make the actual POST request.
      # @param [Hash] config. This should be a hash with a `:address` item in it.
      #   This is where we'll be making a post request to.
      def initialize(poster = Net::HTTP, config = default_config)
        @poster = poster
        @config = config
      end

      # @raise [error_class]
      # @param [request_class?] req
      # @return [response_class]
      def request(req)
        OpenTracing.start_active_span("ExternalService.#{label}") do |scope|
          scope.span.set_tag("peer.address", uri)
          scope.span.set_tag("span.kind", "client")
          headers = {}
          OpenTracing.inject(scope.span.context, OpenTracing::FORMAT_TEXT_MAP, headers)
          response_class.new(poster.post(uri, req.to_json, headers))
        rescue StandardError => e
          scope.span.set_tag("error", true)
          scope.span.log_kv(:"error.kind" => e.class,
                            :"error.object" => e.class,
                            :message => e.message,
                            :stack => e.backtrace)

          raise error_class, "unable to make request: #{e}"
        end
      end

    private

      attr_reader :config, :poster

      # @return [URI]
      def uri
        URI(config[:address])
      end

      define_method :label do
        label
      end

      define_method :default_config do
        default_config
      end

      define_method :response_class do
        response_class
      end

      define_method :error_class do
        error_class
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
