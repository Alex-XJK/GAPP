class CreateVizFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :viz_files do |t|
      t.integer :visualizer_id
      t.json :fileMap
    end
  end
end
