class CreateConnections < ActiveRecord::Migration[6.0]
  def change
    create_table :connections do |t|
      t.references :user, :null => false, :foreign_key => true
      t.references :book, :null => false, :foreign_key => true
      t.string :data_source

      t.timestamps
    end
  end
end
