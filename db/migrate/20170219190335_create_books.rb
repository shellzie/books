class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.decimal :price
      t.date :publish_date
      t.text :image_path
      t.string :cover_type
      t.decimal :price
      t.string :ISBN-10
      t.string :ISBN-13
      t.text :description
      t.string :age
      t.string :grade
      t.float :weight
      t.string :dimensions
      t.text :tags
      t.string :series
      t.integer :pages
      t.string :publisher
      t.string :lexile

      t.timestamps null: false
    end
  end
end

