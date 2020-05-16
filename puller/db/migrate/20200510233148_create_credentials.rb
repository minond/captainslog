class CreateCredentials < ActiveRecord::Migration[6.0]
  def change
    create_table :credentials do |t|
      t.references :user, :null => false, :foreign_key => true
      t.references :connection, :null => false, :foreign_key => true

      t.timestamps
    end
  end
end
