class AddDigestToEntries < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :digest, :text
  end
end
