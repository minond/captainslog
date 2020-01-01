class Entry < ApplicationRecord
  belongs_to :book
  belongs_to :collection
  belongs_to :user

  alias_attribute :data, :processed_data

  after_initialize :constructor
  after_save :schedule_processing, :if => :saved_change_to_original_text?

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
    @user_data ||= data.filter { |key, _val| !key.starts_with?("_") }.sort
  end

private

  def constructor
    self.data ||= {}
  end

  def schedule_processing
    ProcessEntryJob.perform_later self
  end
end
