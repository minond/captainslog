class CreateJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :jobs do |t|
      t.references :user, :null => false, :foreign_key => true
      t.integer :status
      t.integer :kind
      t.text :args
      t.text :logs

      t.timestamps
    end
  end
end
