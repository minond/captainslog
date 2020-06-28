class DropJobs < ActiveRecord::Migration[6.0]
  def change
    drop_table :jobs
  end
end
