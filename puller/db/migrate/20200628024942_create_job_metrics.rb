class CreateJobMetrics < ActiveRecord::Migration[6.0]
  def change
    create_table :job_metrics do |t|
      t.references :user, :null => false, :foreign_key => true
      t.references :job, :null => false, :foreign_key => true
      t.references :connection, :null => false, :foreign_key => true
      t.integer :job_status
      t.integer :run_time

      t.timestamps
    end
  end
end
