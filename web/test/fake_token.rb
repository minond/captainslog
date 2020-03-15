class FakeToken
  def initialize(options = {})
    @options = options
  end

  def token
    "123"
  end

  def refresh_token
    "321"
  end

  def expires_at
    123
  end

  def [](key)
    @options[key]
  end
end
