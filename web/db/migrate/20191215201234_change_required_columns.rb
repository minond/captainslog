class ChangeRequiredColumns < ActiveRecord::Migration[6.0]
  def up
    change_column :books, :name, :string, :null => false
    change_column :books, :grouping, :integer, :null => false
    change_column :collections, :open, :boolean, :null => false
  end

  def down
    change_column :books, :name, :string, :null => true
    change_column :books, :grouping, :integer, :null => true
    change_column :collections, :open, :boolean, :null => true
  end
end
