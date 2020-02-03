class CreateReportVariables < ActiveRecord::Migration[6.0]
  def change
    create_table :report_variables do |t|
      t.string :label, :null => false
      t.string :default_value
      t.text :query
      t.references :user, :null => false, :foreign_key => true
      t.references :report, :null => false, :foreign_key => true

      t.timestamps
    end
  end
end
