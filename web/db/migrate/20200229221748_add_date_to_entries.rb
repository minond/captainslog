class AddDateToEntries < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :date, :datetime
  end
end
