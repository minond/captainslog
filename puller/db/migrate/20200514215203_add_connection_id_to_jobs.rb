class AddConnectionIdToJobs < ActiveRecord::Migration[6.0]
  def change
    add_reference :jobs, :connection, :null => false, :foreign_key => true
  end
end
