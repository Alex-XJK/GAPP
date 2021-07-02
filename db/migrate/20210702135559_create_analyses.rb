class CreateAnalyses < ActiveRecord::Migration[6.0]
  def change
    create_table :analyses do |t|
      t.string :name, null:false
      t.integer :doap_id, null: false
    end
  end
end
