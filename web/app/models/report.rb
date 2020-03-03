class Report < ApplicationRecord
  belongs_to :user
  has_many :report_outputs, :dependent => :destroy
  has_many :report_variables, :dependent => :destroy

  alias_attribute :outputs, :report_outputs
  alias_attribute :variables, :report_variables

  validates :label, :user, :presence => true

  def dump
    {
      :id => id,
      :label => label,
      :variables => dump_variables,
      :outputs => dump_outputs
    }
  end

  def dump_variables
    variables.map do |variable|
      {
        :id => variable.id,
        :label => variable.label,
        :query => variable.query,
        :defaultValue => variable.default_value
      }
    end
  end

  def dump_outputs
    outputs.map do |output|
      {
        :id => output.id,
        :label => output.label,
        :width => output.width,
        :height => output.height,
        :kind => output.kind,
        :query => output.query
      }
    end
  end
end
