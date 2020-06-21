class Service::Record
  attr_reader :text, :datetime

  def initialize(text, datetime)
    @text = text
    @datetime = datetime.to_datetime
  end

  # @return [String]
  def digest
    raise NotImplementedError, "#digest is not implemented"
  end
end
