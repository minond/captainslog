class Credential < ApplicationRecord
  belongs_to :user
  has_many :credential_options, :dependent => :destroy

  validates :data_source, :user, :presence => true

  scope :by_data_source, ->(ds) { find_by(:data_source => ds) }

  # Creates a credential record with all of its associated credential options.
  # Each credential option is encrypted using the user that is associated with
  # the credential.
  #
  # @param [Hash] options
  # @return [Credential]
  def self.create_with_options(user, data_source, options)
    Credential.transaction do
      credential = create(:user => user,
                          :data_source => data_source)

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
    credential_options.reduce({}) do |options, option|
      options[option.label] = option.decrypted_value
      options
    end
  end
end
