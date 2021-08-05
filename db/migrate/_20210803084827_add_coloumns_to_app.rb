class AddColoumnsToApp < ActiveRecord::Migration[6.0]
  def change
    add_column :apps, :cover_image, :string
    add_column :apps, :panel, :string
  end
end
