class RenameSourceToServiceInConnections < ActiveRecord::Migration[6.0]
  def change
    rename_column :connections, :source, :service
  end
end
