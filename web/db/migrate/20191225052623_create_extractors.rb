class CreateExtractors < ActiveRecord::Migration[6.0]
  def change
    create_table :extractors do |t|
      t.string :label, :null => false
      t.string :match, :null => false
      t.belongs_to :book, :null => false, :foreign_key => true
      t.timestamps :null => false
    end
  end
end
