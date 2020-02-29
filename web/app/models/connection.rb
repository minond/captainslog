class Connection < ApplicationRecord
  belongs_to :user
  belongs_to :book, :optional => true
  has_many :credentials, :dependent => :destroy

  validates :data_source, :user, :presence => true
  validate :ensure_book_owner

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

  def newest_credentials
    credentials.order("created_at desc").first
  end

  def ensure_book_owner
    user.books.find(book_id)
  rescue ActiveRecord::RecordNotFound
    errors.add(:book, "not found")
  end
end
