class Entry < ApplicationRecord
  belongs_to :book
  belongs_to :collection
  belongs_to :user

  alias_attribute :processed_data, :data

  after_initialize :constructor
  after_save :schedule_processing, :if => :saved_change_to_original_text?

  before_save :reset_processed_text, :if => :will_save_change_to_original_text?,
                                     :unless => :will_save_change_to_processed_text?
  before_save :reset_processed_data, :if => :will_save_change_to_original_text?,
                                     :unless => :will_save_change_to_processed_data?

  validates :book, :collection, :user, :original_text, :presence => true

  scope :by_user, ->(user) { where(:user => user) }
  scope :by_text, ->(text) { where("processed_text ilike ?", "%#{text}%") }

  # @return [String]
  def text
    processed_text || original_text
  end

  # Human friendly data
  #
  # @return [Hash]
  def user_data
    @user_data ||= processed_data.filter { |key, _val| !key.starts_with?("_") }.sort
  end

  # @return [Boolean]
  def user_data?
    !user_data.empty?
  end

  # Returns the book/collection URL in which this entry can be loaded.
  #
  # @return [String]
  def collection_path
    Rails.application.routes.url_helpers.book_at_path(book.slug, collection.datetime.to_i)
  end

  def schedule_processing
    ProcessEntryJob.perform_later self
  end

private

  def constructor
    self.processed_data ||= {}
  end

  def reset_processed_text
    self.processed_text = nil
  end

  def reset_processed_data
    self.processed_data = nil
  end
end
