class RenameTailHeadReferencesInEdges < ActiveRecord::Migration[6.0]
  def change
    rename_column :edges, :tail_id, :source_id
    rename_column :edges, :head_id, :target_id
  end
end
