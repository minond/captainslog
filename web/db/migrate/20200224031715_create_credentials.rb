class CreateCredentials < ActiveRecord::Migration[6.0]
  def change
    create_table :credentials do |t|
      t.references :user, :null => false, :foreign_key => true
      t.string :data_source, :null => false

      t.timestamps
    end
  end
end
