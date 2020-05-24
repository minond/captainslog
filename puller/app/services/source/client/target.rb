module Source::Client::Target
  extend extend ActiveSupport::Concern

  ID = Struct.new(:id, :label, :keyword_init => true)

  # @param [Array<Source::Record>] records
  # @param [ID] id
  def push(_records, _id)
    raise NotImplementedError, "#push is not implemented"
  end

  # @return [Array<ID>]
  def available_targets
    raise NotImplementedError, "#available_targets is not implemented"
  end
end
