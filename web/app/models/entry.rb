class Entry < ApplicationRecord
  belongs_to :book
  belongs_to :collection

  after_initialize :constructor
  after_create :schedule_processing

  validates :book, :collection, :original_text, :presence => true

  def text
    processed_text || original_text
  end

  def text=(text)
    self.processed_text = text
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
