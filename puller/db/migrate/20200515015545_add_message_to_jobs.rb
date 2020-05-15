class AddMessageToJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :jobs, :message, :text
  end
end
