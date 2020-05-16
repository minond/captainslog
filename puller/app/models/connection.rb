class Connection < ApplicationRecord
  belongs_to :user
  has_many :credentials, :dependent => :destroy
  has_many :jobs, :dependent => :destroy

  validates :source, :user, :presence => true

  after_create :schedule_backfill

  scope :last_update_attempted_over, ->(datetime) { where("last_updated_at < ?", datetime) }

  class MissingCredentialsError < StandardError; end

  # @param [Integer] limit, number of connections to retrieve
  # @param [ActiveSupport::TimeWithZone] last_update_attempted_over_datetime
  # @return [Array<Connection>]
  def self.in_need_of_data_pull(limit = 10, last_update_attempted_over_datetime = 6.hours.ago)
    last_update_attempted_over(last_update_attempted_over_datetime)
      .order("random()")
      .limit(limit)
  end

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

  def recent_stats(last_n_jobs = 10)
    jobs.select(:id, :status, "extract(epoch from stopped_at - started_at) as run_time")
        .order("created_at desc")
        .first(last_n_jobs)
        .pluck(:id, :status, :run_time)
  end

  # @return [Job]
  def schedule_pull
    schedule_job(:pull)
  end

  # @return [Job]
  def schedule_backfill
    schedule_job(:backfill)
  end

private

  # @return [Credential, nil]
  def newest_credentials
    credentials.order("created_at desc").first
  end

  # @return [Job]
  def schedule_job(kind)
    Job.create(:user => user,
               :connection => self,
               :kind => kind)
  end
end
