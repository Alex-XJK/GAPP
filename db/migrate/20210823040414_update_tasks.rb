class UpdateTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :task_id, :string
    remove_column :tasks, :status, :integer
    add_column :tasks, :status, :string
  end
end
