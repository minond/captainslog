class AddLastUpdateJobIdToConnections < ActiveRecord::Migration[6.0]
  def change
    add_column :connections, :last_update_job_id, :bigint
  end
end
