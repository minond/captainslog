class RemoveDataSourceFromCredentials < ActiveRecord::Migration[6.0]
  def change
    remove_column :credentials, :data_source, :string
  end
end
