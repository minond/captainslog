class AddLastPulledAtToConnections < ActiveRecord::Migration[6.0]
  def change
    add_column :connections, :last_updated_at, :datetime
  end
end
