class CreateEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :entries do |t|
      t.belongs_to :book, :null => false, :foreign_key => true
      t.belongs_to :collection, :null => false, :foreign_key => true
      t.text :original_text
      t.text :processed_text
      t.jsonb :processed_data

      t.timestamps
    end
  end
end
