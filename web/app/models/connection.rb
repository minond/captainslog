class Connection < ApplicationRecord
  include OwnerValidation

  class MissingCredentialsError < StandardError; end

  belongs_to :user
  belongs_to :book, :optional => true
  has_many :credentials, :dependent => :destroy
  has_many :entries, :dependent => :destroy

  after_commit :schedule_data_pull_backfill, :if => :needs_initial_data_pull?

  validates :data_source, :user, :presence => true
  validate :book_is_owned_by_user, :if => :book_id

  scope :by_data_source, ->(ds) { find_by(:data_source => ds) }
  scope :last_update_attempted_over, ->(datetime) { where("last_update_attempted_at < ?", datetime) }
  scope :is_active, -> { where.not(:book_id => nil) }
  scope :in_random_order, -> { order("random()") }

  # @param [Integer] limit, number of connections to retrieve
  # @param [ActiveSupport::TimeWithZone] last_update_attempted_over_datetime
  # @return [Array<Connection>]
  def self.in_need_of_data_pull(limit = 10, last_update_attempted_over_datetime = 6.hours.ago)
    is_active
      .last_update_attempted_over(last_update_attempted_over_datetime)
      .in_random_order
      .limit(limit)
  end

  # @return [DataSource::Client]
  def client
    raise MissingCredentialsError, "no credentials found for connection" unless newest_credentials

    @client ||=
      begin
        klass = DataSource::Client.for_data_source(data_source)
        klass.new(newest_credentials.options)
      end
  end

  # @return [Job]
  def schedule_data_pull_backfill
    schedule_data_pull(:connection_data_pull_backfill,
                       Job::ConnectionDataPullBackfillArgs.new(:connection_id => id))
  end

  # @return [Job]
  def schedule_data_pull_standard
    return last_update_job if scheduled_data_pull_within(15.minutes)

    schedule_data_pull(:connection_data_pull_standard,
                       Job::ConnectionDataPullStandardArgs.new(:connection_id => id))
  end

private

  # @return [Credential, nil]
  def newest_credentials
    credentials.order("created_at desc").first
  end

  # @return [Boolean]
  def needs_initial_data_pull?
    book_id? && book_id_previously_changed?
  end

  # @return [Job, nil]
  def last_update_job
    return nil unless last_update_job_id

    user.jobs.find(last_update_job_id)
  end

  # @param [ActiveSupport::Duration] duration
  # @return [Boolean]
  def scheduled_data_pull_within(duration)
    return false unless last_update_attempted_at

    duration.ago < last_update_attempted_at
  end

  # @return [Job]
  def schedule_data_pull(kind, args)
    Connection.transaction do
      job = Job.schedule!(user, kind, args)
      update(:last_update_attempted_at => Time.now, :last_update_job_id => job.id)
      job
    end
  end
end
