class CreateVertices < ActiveRecord::Migration[6.0]
  def change
    create_table :vertices do |t|
      t.references :user, :null => false, :foreign_key => true
      t.references :connection, :null => false, :foreign_key => true
      t.text :urn

      t.timestamps
    end
  end
end
