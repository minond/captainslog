# Makes a few extensions to the JWT gem's base module. It adds methods that
# make encoding and decoding JWTs much easier to do.
module JWT
  # @param [Hash] payload
  # @param [ActiveSupport::TimeWithZone] exp
  # @return [String]
  def self.encode_application_token(payload, exp = 30.days.from_now)
    encode(payload.merge(:exp => exp.to_i), secret)
  end

  # @param [String] token
  # @return [Hash]
  def self.decode_application_token(token)
    decode(token, secret).first.with_indifferent_access rescue nil
  end

  # @return [String]
  def self.secret
    Rails.application.secrets.secret_key_base
  end
end
