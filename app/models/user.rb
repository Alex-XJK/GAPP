class User < ApplicationRecord
    has_many :datum
    has_many :task
end
