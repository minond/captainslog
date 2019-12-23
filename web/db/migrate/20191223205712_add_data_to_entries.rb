class AddDataToEntries < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :data, :jsonb
  end
end
