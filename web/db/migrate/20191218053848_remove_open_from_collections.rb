class RemoveOpenFromCollections < ActiveRecord::Migration[6.0]
  def change
    remove_column :collections, :open, :boolean
  end
end
