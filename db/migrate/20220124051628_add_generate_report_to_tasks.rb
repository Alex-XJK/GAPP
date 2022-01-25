class AddGenerateReportToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :generate_report, :boolean
  end
end
