class CredentialOption < ApplicationRecord
  belongs_to :credential

  validates :label, :value, :credential, :presence => true

  # @return [String]
  def decrypted_value
    credential.user.decrypt_value(value) if value.present?
  end

  # @param [String] value
  def value=(value)
    self[:value] = credential.user.encrypt_value(value)
  end
end
