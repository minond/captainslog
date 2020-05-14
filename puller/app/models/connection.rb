class Connection < ApplicationRecord
  belongs_to :user
  has_many :credentials, :dependent => :destroy

  validates :source, :user, :presence => true

  # @param [Hash] connection_attrs
  # @param [Hash] credentials_hash
  # @return [Connection]
  def self.create_with_credentials(connection_attrs, credentials_hash)
    transaction do
      connection = create(connection_attrs)
      Credential.create_with_options(connection, credentials_hash)
      connection
    end
  end
end
