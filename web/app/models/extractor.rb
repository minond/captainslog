class Extractor < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :user
  belongs_to :book
end
