class User < ApplicationRecord
    has_many :task
    has_many_attached :dataFiles
end
