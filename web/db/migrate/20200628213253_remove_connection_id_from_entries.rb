class RemoveConnectionIdFromEntries < ActiveRecord::Migration[6.0]
  def change
    remove_column :entries, :connection_id
  end
end
