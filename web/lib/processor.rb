require "net/http"
require "uri"

module Processor
  class Error < StandardError; end

  # RequestError represents an error that occured _while making_ the request to
  # the processing service.
  class RequestError < Error; end

  # ProcessingError represents an error _from_ the processing service. This
  # means the request was successful, but there was an error in processing the
  # text.
  class ProcessingError < Error; end

  Request = Struct.new(:book_id, :text, :keyword_init => true)
end
