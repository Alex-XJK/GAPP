class AddAppToTask < ActiveRecord::Migration[6.0]
  def change
    add_reference :tasks, :app, null: false, foreign_key: true
  end
end
