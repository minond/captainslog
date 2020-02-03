class CreateReportOutputs < ActiveRecord::Migration[6.0]
  def change
    create_table :report_outputs do |t|
      t.string :label, :null => false
      t.string :width
      t.string :height
      t.integer :kind, :null => false
      t.text :query
      t.references :user, :null => false, :foreign_key => true
      t.references :report, :null => false, :foreign_key => true

      t.timestamps
    end
  end
end
