class CreateApp < ActiveRecord::Migration[6.0]
  def change
    create_table :apps do |t|
      t.string :app_no, unique:true, null:false
      t.string :name, null:false
      t.integer :price, null: false
      t.text :description, null: false
      t.boolean :create_report, default: false
      t.string :status, default:"offline"
      t.belongs_to :user
      t.belongs_to :analysis 
      t.string :cover_image
      t.string :panel
      t.timestamps
    end
  end
end
