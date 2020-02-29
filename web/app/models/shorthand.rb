class Shorthand < ApplicationRecord
  include BookProcessingScheduling
  include OwnerValidation

  belongs_to :user
  belongs_to :book

  after_commit :schedule_book_reprocessing

  validates :priority, :expansion, :book, :user, :presence => true
  validate :book_is_owned_by_user
end
