class Report < ApplicationRecord
  belongs_to :user
  has_many :report_outputs
  has_many :report_variables

  alias_attribute :outputs, :report_outputs
  alias_attribute :variables, :report_variables

  validates :label, :user, :presence => true

  scope :by_user, ->(user) { where(:user => user) }
  scope :by_id, ->(id) { find(id) }
end
