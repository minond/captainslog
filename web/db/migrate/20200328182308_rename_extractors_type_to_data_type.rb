class RenameExtractorsTypeToDataType < ActiveRecord::Migration[6.0]
  def up
    add_column :extractors, :data_type, :integer
    execute "update extractors set data_type = type"
    remove_column :extractors, :type
  end

  def down
    add_column :extractors, :type, :integer
    execute "update extractors set type = data_type"
    remove_column :extractors, :data_type
  end
end
