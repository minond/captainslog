class AddLastUpdateAttemptedAtToConnections < ActiveRecord::Migration[6.0]
  def change
    add_column :connections, :last_update_attempted_at, :datetime
  end
end
