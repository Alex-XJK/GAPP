class CreateVisualizers < ActiveRecord::Migration[6.0]
  def change
    create_table :visualizers do |t|
      t.string :name
      t.string :js_module_name
      t.json :load_data

      t.timestamps
    end
  end
end
