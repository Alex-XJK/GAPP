class VizFileObject < ApplicationRecord
    mount_uploader :file, KeyedFileUploader
    belongs_to :analysis
    belongs_to :user
    belongs_to :viz_data_source
end
