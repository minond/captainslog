class Connection < ApplicationRecord
  belongs_to :user
  has_many :credentials, :dependent => :destroy
  has_many :jobs, :dependent => :destroy
  has_many :vertices, :dependent => :destroy

  validates :service, :user, :presence => true

  scope :last_update_attempted_over, ->(datetime) { where("last_updated_at < ?", datetime) }

  delegate :source?, :to => :new_unauthenticated_client
  delegate :target?, :to => :new_unauthenticated_client
  delegate :available_sources, :to => :client_class
  delegate :available_targets, :to => :client

  class MissingCredentialsError < StandardError; end

  # @param [Integer] limit, number of connections to retrieve
  # @param [ActiveSupport::TimeWithZone] last_update_attempted_over_datetime
  # @return [Array<Connection>]
  def self.in_need_of_pull(limit = 10, last_update_attempted_over_datetime = 6.hours.ago)
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

  # @return [Service::Client]
  def client
    @client ||=
      begin
        raise MissingCredentialsError if newest_credentials.nil?

        new_authenticated_client
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
    schedule_job(:pull) if source?
  end

  # @return [Job]
  def schedule_backfill_pull
    schedule_job(:backfill) if source?
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

  # @return [Class]
  def client_class
    Service.class_for_service(service)
  end

  # @return [Service::Client]
  def new_unauthenticated_client
    client_class.new
  end

  # @return [Service::Client]
  def new_authenticated_client
    client_class.new(newest_credentials.options)
  end
end
