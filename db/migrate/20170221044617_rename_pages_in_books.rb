class RenamePagesInBooks < ActiveRecord::Migration
  def change
    rename_column :books, :num_pages, :pages
  end
end
