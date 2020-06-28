class DropCredentails < ActiveRecord::Migration[6.0]
  def change
    drop_table :credential_options
    drop_table :credentials
  end
end
