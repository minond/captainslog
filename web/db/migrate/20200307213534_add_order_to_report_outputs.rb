class AddOrderToReportOutputs < ActiveRecord::Migration[6.0]
  def change
    add_column :report_outputs, :order, :integer
  end
end
