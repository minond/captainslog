class Service::Record
  attr_reader :text, :date

  def initialize(text, date)
    @text = text
    @date = date
  end

  # @return [String]
  def digest
    raise NotImplementedError, "#digest is not implemented"
  end
end
