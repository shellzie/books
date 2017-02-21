class RenameFieldsInBooks < ActiveRecord::Migration
  def change
    rename_column :books, :age_range, :age
    rename_column :books, :grade_level, :grade
    rename_column :books, :publication_date, :publish_date
    rename_column :books, :isbn, :ISBN10
    add_column :books, :ISBN13, :string
    add_column :books, :lexile, :string
    remove_column :books, :num_reviews
    remove_column :books, :rating
  end
end
