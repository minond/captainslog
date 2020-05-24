class CreateEdges < ActiveRecord::Migration[6.0]
  def change
    create_table :edges do |t|
      t.references :user, :null => false, :foreign_key => true
      t.bigint :tail_id, :null => false, :foreign_key => true
      t.bigint :head_id, :null => false, :foreign_key => true

      t.timestamps
    end
  end
end
