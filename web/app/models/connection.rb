class Connection < ApplicationRecord
  belongs_to :user
  belongs_to :book
  has_many :credentials, :dependent => :destroy

  validates :data_source, :user, :presence => true

  scope :by_data_source, ->(ds) { find_by(:data_source => ds) }

  # @return [Puller::Client]
  def puller
    @puller ||=
      begin
        klass = Puller::Client.for_data_source(data_source)
        klass.new(newest_credentials.options)
      end
  end

private

  def newest_credentials
    credentials.order("created_at desc").first
  end
end
