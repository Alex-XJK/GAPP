class AddColoumsToCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :initial, :string
    add_column :categories, :serial, :integer
  end
end
