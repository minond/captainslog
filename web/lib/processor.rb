require "net/http"
require "uri"

module Processor
  Error = Class.new(ExternalService::Error)

  # RequestError represents an error that occured _while making_ the request to
  # the processing service.
  RequestError = Class.new(Error)

  # ProcessingError represents an error _from_ the processing service. This
  # means the request was successful, but there was an error in processing the
  # text.
  ProcessingError = Class.new(Error)

  Client = ExternalService.client(Processor::Response,
                                  Processor::RequestError,
                                  Rails.application.config.processor)
end
