class Extractor < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :user
  belongs_to :book

  after_initialize :constructor
  after_commit :schedule_reprocessing

  validates :label, :match, :book, :user, :type, :presence => true

private

  def constructor
    self.user ||= book&.user
  end

  # Reprocess all of the book's entries to take into account this recent
  # change.
  def schedule_reprocessing
    book.schedule_reprocessing
  end
end
