class RemoveArgsFromJobs < ActiveRecord::Migration[6.0]
  def change
    remove_column :jobs, :args, :text
  end
end
