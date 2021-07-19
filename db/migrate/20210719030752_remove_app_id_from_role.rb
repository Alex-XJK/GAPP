class RemoveAppIdFromRole < ActiveRecord::Migration[6.0]
  def change
    remove_column :roles, :app_id, :integer
  end
end
