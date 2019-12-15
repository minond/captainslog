class Book < ApplicationRecord
  belongs_to :user

  after_initialize :constructor

  enum :grouping => [:none, :day], :_prefix => :group_by

private

  def constructor
    self.grouping ||= Book.groupings[:none]
  end
end
