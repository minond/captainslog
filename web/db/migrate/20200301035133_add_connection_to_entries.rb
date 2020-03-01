class AddConnectionToEntries < ActiveRecord::Migration[6.0]
  def change
    add_reference :entries, :connection, :null => true, :foreign_key => true
  end
end
