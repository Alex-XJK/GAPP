class Add2ColumnsToAnalysis < ActiveRecord::Migration[6.0]
  def change
    add_column :analyses, :param_for_userid, :string
    add_column :analyses, :param_for_filename, :string
  end
end
