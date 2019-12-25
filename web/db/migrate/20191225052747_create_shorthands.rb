class CreateShorthands < ActiveRecord::Migration[6.0]
  def change
    create_table :shorthands do |t|
      t.integer :priority, :null => false
      t.string :expansion, :null => false
      t.string :match
      t.string :text
      t.belongs_to :book, null: false, foreign_key: true
      t.timestamps :null => false
    end
  end
end
