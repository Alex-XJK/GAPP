class App < ApplicationRecord

  validates :app_no, presence: true
  validates :name, presence: true
  validates :price, presence: true
  validates :description, presence: true
  validates :status, presence: true
  validates :user_id, presence: true
  validates :analysis_id, presence: true

  belongs_to :analysis
  belongs_to :user

  has_one_attached :cover_image
  has_one_attached :panel
end
