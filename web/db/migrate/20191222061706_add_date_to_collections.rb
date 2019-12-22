class AddDateToCollections < ActiveRecord::Migration[6.0]
  def change
    add_column :collections, :datetime, :datetime, :null => false
  end
end
