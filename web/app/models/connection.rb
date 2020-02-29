class Connection < ApplicationRecord
  include OwnerValidation

  belongs_to :user
  belongs_to :book, :optional => true
  has_many :credentials, :dependent => :destroy

  validates :data_source, :user, :presence => true
  validate :book_is_owned_by_user, :if => :book_id

  scope :by_data_source, ->(ds) { find_by(:data_source => ds) }

  # @return [DataSource::Client]
  def client
    @client ||=
      begin
        klass = DataSource::Client.for_data_source(data_source)
        klass.new(newest_credentials.options)
      end
  end

private

  # @return [Credential, nil]
  def newest_credentials
    credentials.order("created_at desc").first
  end
end
