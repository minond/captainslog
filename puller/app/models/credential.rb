class Credential < ApplicationRecord
  belongs_to :user
  belongs_to :connection
  has_many :credential_options, :dependent => :destroy

  validates :user, :connection, :presence => true

  # Creates a credential record with all of its associated credential options.
  # Each credential option is encrypted using the user that is associated with
  # the credential.
  #
  # @param [Connection] connection
  # @param [Hash] credentials_hash
  # @return [Credential]
  def self.create_with_options(connection, credentials_hash)
    credential = create(:user => connection.user,
                        :connection => connection)

    credentials_hash.each do |label, value|
      CredentialOption.create(:credential => credential,
                              :label => label,
                              :value => value)
    end

    credential
  end

  # Loads all credential options associated with this credential and decrypts
  # their values using the user that owns this credential.
  #
  # @return [Hash]
  def options
    credential_options.each_with_object({}.with_indifferent_access) do |option, container|
      container[option.label] = option.decrypted_value
    end
  end
end
