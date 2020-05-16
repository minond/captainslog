class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :encrypted_password
      t.text :salt

      t.timestamps

      t.index [:email], :name => "index_users_on_email", :unique => true
    end
  end
end
