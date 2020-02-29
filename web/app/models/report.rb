class Report < ApplicationRecord
  belongs_to :user
  has_many :report_outputs, :dependent => :destroy
  has_many :report_variables, :dependent => :destroy

  alias_attribute :outputs, :report_outputs
  alias_attribute :variables, :report_variables

  validates :label, :user, :presence => true
end
