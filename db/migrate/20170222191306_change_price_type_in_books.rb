class ChangePriceTypeInBooks < ActiveRecord::Migration
  def change
    change_column :books, :price, :string
  end
end
