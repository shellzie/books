class ChangeWeightTypeInBooks < ActiveRecord::Migration
  def change
    change_column :books, :weight, :string
  end
end
