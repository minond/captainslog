class Connection < ApplicationRecord
  belongs_to :user
  has_many :credentials, :dependent => :destroy
  has_many :jobs, :dependent => :destroy

  validates :source, :user, :presence => true

  after_create :schedule_backfill

  class MissingCredentialsError < StandardError; end

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

  # @return [Source::Client]
  def client
    @client ||=
      begin
        raise MissingCredentialsError if newest_credentials.nil?

        klass = Source::Client.class_for_source(source)
        klass.new(newest_credentials.options)
      end
  end

private

  # @return [Credential, nil]
  def newest_credentials
    credentials.order("created_at desc").first
  end

  def schedule_backfill
    ScheduleBackfillJob.call(self)
  end
end
