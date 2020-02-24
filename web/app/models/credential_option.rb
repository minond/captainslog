class CredentialOption < ApplicationRecord
  belongs_to :credential

  validates :label, :value, :credential, :presence => true

  # @return [String]
  def decrypted_value
    decrypt(value) if value.present?
  end

  # @param [String] value
  def value=(value)
    self[:value] = encrypt(value)
  end

private

  # @param [String] value
  # @return [String]
  def decrypt(value)
    credential.user.decrypt_value(value)
  end

  # @param [String] value
  # @return [String]
  def encrypt(value)
    credential.user.encrypt_value(value)
  end
end
