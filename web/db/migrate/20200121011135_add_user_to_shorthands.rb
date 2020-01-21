class AddUserToShorthands < ActiveRecord::Migration[6.0]
  def change
    add_reference :shorthands, :user, :null => false, :foreign_key => true
  end
end
