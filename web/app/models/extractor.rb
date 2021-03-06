class Extractor < ApplicationRecord
  include BookProcessingScheduling
  include OwnerValidation

  belongs_to :user
  belongs_to :book

  after_commit :schedule_book_reprocessing

  validates :label, :match, :book, :user, :data_type, :presence => true
  validate :book_is_owned_by_user

  enum :data_type => %i[string number boolean]

  default_scope { order(:label => :asc) }
end
