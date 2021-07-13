class AddCategoryToApp < ActiveRecord::Migration[6.0]
  def change
    add_reference :apps, :category, foreign_key: true
  end
end
