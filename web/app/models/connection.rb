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

  # @return [Job]
  def schedule_initial_data_pull
    Job.schedule!(user, :connection_data_pull, initial_data_pull_args)
  end

  # @return [Job::ConnectionDataPullArgs]
  def initial_data_pull_args
    Job::ConnectionDataPullArgs.new(:connection_id => id,
                                    :start_date => 2.years.ago.to_date,
                                    :end_date => Date.current)
  end

  # @return [Boolean]
  def needs_initial_data_pull?
    book_id? && book_id_previously_changed?
  end
end
