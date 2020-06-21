class Connection < ApplicationRecord
  include Broadcaster
  include Performer

  performs CreateVerticesJob

  belongs_to :user
  has_many :credentials, :dependent => :destroy
  has_many :jobs, :dependent => :destroy
  has_many :vertices, :dependent => :destroy

  validates :service, :user, :presence => true

  after_create :perform_create_vertices_later
  after_touch :broadcast_user_connection

  scope :last_update_attempted_over, ->(datetime) { where("last_updated_at < ?", datetime) }

  delegate :source?, :to => :new_unauthenticated_client
  delegate :target?, :to => :new_unauthenticated_client
  delegate :available_source_resources, :to => :client_class
  delegate :available_target_resources, :to => :client

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

  # @return [Array<Service::Resource>]
  def available_resources
    source? ? available_source_resources : available_target_resources
  end

  # @return [Service::Client]
  def client
    @client ||=
      begin
        raise MissingCredentialsError if newest_credentials.nil?

        new_authenticated_client
      end
  end

  # @param [Integer] last_n_jobs
  # @return [Tuple<Integer, Symbol, :Integer>]
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

  # Creates a Vertex for every available resource. Vertices are created for a
  # services before they are used as a way to cache the available sources or
  # targets. This is particularly helpful for target services, which require an
  # external call in order to retrieve available resources.
  #
  # @return [Array<Vertex>]
  def create_vertices!
    available_resources.map do |resource|
      Vertex.create(:user => user,
                    :connection => self,
                    :resource => resource)
    end
  end

  # @yieldparam [Vertex, Edge]
  # @yieldparam [Edge, Vertex]
  def find_each_endpoint
    direction = source? ? :outgoing : :incoming
    vertices.find_each do |vertex|
      vertex.send(direction).find_each do |edge|
        if source?
          yield vertex, edge.target
        else
          yield edge.source, vertex
        end
      end
    end
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
