class AddProcessedAtToEntries < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :processed_at, :datetime
  end
end
