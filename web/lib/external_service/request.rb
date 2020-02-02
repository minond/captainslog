module ExternalService
  class Request
    # @param [Any] _args defined to meet requirements for `JSON.generate`
    # @return [String]
    def to_json(*_args)
      to_hash.to_json
    end
  end
end
