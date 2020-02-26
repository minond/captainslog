class MakeConnectionsBookNullable < ActiveRecord::Migration[6.0]
  def change
    change_column :connections, :book_id, :bigint, :null => true
  end
end
