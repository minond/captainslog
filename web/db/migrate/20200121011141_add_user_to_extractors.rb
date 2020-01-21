class AddUserToExtractors < ActiveRecord::Migration[6.0]
  def change
    add_reference :extractors, :user, :null => false, :foreign_key => true
  end
end
