class Connection < ApplicationRecord
  include OwnerValidation

  belongs_to :user
  belongs_to :book, :optional => true
  has_many :credentials, :dependent => :destroy
  has_many :entries, :dependent => :destroy

  after_commit :schedule_initial_data_pull, :if => :needs_initial_data_pull?

  validates :data_source, :user, :presence => true
  validate :book_is_owned_by_user, :if => :book_id

  scope :by_data_source, ->(ds) { find_by(:data_source => ds) }
  scope :last_update_attempted_over, ->(datetime) { where("last_update_attempted_at < ?", datetime) }
  scope :is_active, -> { where.not(:book_id => nil) }
  scope :in_random_order, -> { order("random()") }

  # @return [DataSource::Client]
  def client
    @client ||=
      begin
        klass = DataSource::Client.for_data_source(data_source)
        klass.new(newest_credentials.options)
      end
  end

  # @param [Date] start_date
  # @return [Job]
  def schedule_data_pull(start_date = 2.days.ago.to_date)
    Connection.transaction do
      update(:last_update_attempted_at => Time.now)
      Job.schedule!(user, :connection_data_pull, data_pull_job_args(start_date))
    end
  end

private

  # @return [Credential, nil]
  def newest_credentials
    credentials.order("created_at desc").first
  end

  # @return [Job]
  def schedule_initial_data_pull
    schedule_data_pull(2.years.ago.to_date)
  end

  # @param [Date] start_date
  # @return [Job::ConnectionDataPullArgs]
  def data_pull_job_args(start_date)
    Job::ConnectionDataPullArgs.new(:connection_id => id,
                                    :start_date => start_date,
                                    :end_date => Date.current)
  end

  # @return [Boolean]
  def needs_initial_data_pull?
    book_id? && book_id_previously_changed?
  end
end
