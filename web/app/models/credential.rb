class Credential < ApplicationRecord
  belongs_to :user
  has_many :credential_options, :dependent => :destroy

  validates :user, :presence => true

  # Creates a credential record with all of its associated credential options.
  # Each credential option is encrypted using the user that is associated with
  # the credential.
  #
  # @param [User] user
  # @param [Hash] options
  # @return [Credential]
  def self.create_with_options(user, options)
    Credential.transaction do
      credential = create(:user => user)

      options.each do |label, value|
        CredentialOption.create(:credential => credential,
                                :label => label,
                                :value => value)
      end

      credential
    end
  end

  # Loads all credential options associated with this credential and decrypts
  # their values using the user that owns this credential.
  #
  # @return [Hash]
  def options
    credential_options.each_with_object({}) do |option, container|
      container[option.label] = option.decrypted_value
    end
  end
end
