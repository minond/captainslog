class Credential < ApplicationRecord
  belongs_to :user
  belongs_to :connection

  has_many :credential_options

  validates :user, :connection, :presence => true

  # Creates a credential record with all of its associated credential options.
  # Each credential option is encrypted using the user that is associated with
  # the credential.
  #
  # @param [User] user
  # @param [Connection] connection
  # @param [Hash] options
  # @return [Credential]
  def self.create_with_options(user, connection, options)
    credential = create(:user => user,
                        :connection => connection)

    options.each do |label, value|
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
