class AddConnectionToCredentials < ActiveRecord::Migration[6.0]
  def change
    add_reference :credentials, :connection, :null => false, :foreign_key => true
  end
end
