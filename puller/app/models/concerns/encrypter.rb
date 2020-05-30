module Encrypter
  include ActiveSupport::Concern

  # @param [String] value
  # @return [String]
  def encrypt(value)
    encryptor.encrypt_and_sign(value)
  end

  # @param [String] value
  # @return [String]
  def decrypt(value)
    encryptor.decrypt_and_verify(value)
  end

private

  # @return [String]
  def generate_salt
    SecureRandom.hex(encryption_key_len)
  end

  # @return [String]
  def secret_key_base
    Rails.application.credentials.secret_key_base
  end

  # @return [ActiveSupport::KeyGenerator]
  def new_key_generator
    ActiveSupport::KeyGenerator.new(secret_key_base)
  end

  # @return [Integer]
  def encryption_key_len
    ActiveSupport::MessageEncryptor.key_len
  end

  # @return [String]
  def encryption_key
    new_key_generator.generate_key(salt, encryption_key_len)
  end

  # @return [ActiveSupport::MessageEncryptor]
  def encryptor
    @encryptor ||= ActiveSupport::MessageEncryptor.new(encryption_key)
  end
end
