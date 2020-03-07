class Extractor < ApplicationRecord
  include BookProcessingScheduling
  include OwnerValidation

  self.inheritance_column = :_type_disabled

  belongs_to :user
  belongs_to :book

  after_commit :schedule_book_reprocessing

  validates :label, :match, :book, :user, :type, :presence => true
  validate :book_is_owned_by_user

  default_scope { order(:label => :asc) }
end
