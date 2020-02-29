class RemoveUserFromReportVariables < ActiveRecord::Migration[6.0]
  def up
    remove_column :report_variables, :user_id, :bigint
  end

  def down
    add_reference :report_variables, :user, :null => true, :foreign_key => true
  end
end
