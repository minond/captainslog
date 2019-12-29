class AddSlugToBooks < ActiveRecord::Migration[6.0]
  def change
    add_column :books, :slug, :string, :null => false
    add_index :books, %i[user_id slug], :unique => true, :name => "books_user_id_slug_unique"
  end
end
