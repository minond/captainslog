class AddSaltToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :salt, :text
  end
end
