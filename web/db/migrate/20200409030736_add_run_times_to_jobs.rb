class AddRunTimesToJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :jobs, :started_at, :datetime
    add_column :jobs, :finished_at, :datetime
  end
end
