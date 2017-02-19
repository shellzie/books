class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.date :publication_date
      t.text :image_path
      t.string :cover_type
      t.decimal :price
      t.float :rating
      t.integer :num_reviews
      t.string :isbn
      t.text :description
      t.string :age_range
      t.string :grade_level
      t.float :weight
      t.string :dimensions
      t.text :tags
      t.string :series
      t.integer :num_pages
      t.string :publisher


      t.timestamps null: false
    end
  end
end

