class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :name
      t.string :status, null:false
      t.belongs_to :user
      t.belongs_to :analysis

      t.timestamps
    end
  end
end
