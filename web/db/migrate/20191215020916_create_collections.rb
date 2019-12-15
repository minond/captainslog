class CreateCollections < ActiveRecord::Migration[6.0]
  def change
    create_table :collections do |t|
      t.belongs_to :book, null: false, foreign_key: true
      t.boolean :open

      t.timestamps
    end
  end
end
