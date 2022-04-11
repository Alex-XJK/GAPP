class AddIspipelineToAnalyses < ActiveRecord::Migration[6.0]
  def change
    add_column :analyses, :ispipeline, :boolean
  end
end
