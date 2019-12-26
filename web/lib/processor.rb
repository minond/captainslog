require "net/http"
require "uri"

module Processor
  class Error < StandardError; end

  Request = Struct.new(:book_id, :text, :keyword_init => true)
  Response = Struct.new(:text, :data, :keyword_init => true)
end
