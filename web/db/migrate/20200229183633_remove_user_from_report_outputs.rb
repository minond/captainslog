class RemoveUserFromReportOutputs < ActiveRecord::Migration[6.0]
  def up
    remove_column :report_outputs, :user_id, :bigint
  end

  def down
    add_reference :report_outputs, :user, :null => true, :foreign_key => true
  end
end
