class App < ApplicationRecord
  include Statuscheck

  validates :name, presence: true
  validates :price, presence: true
  validates :description, presence: true
  validates :analysis_id, presence: true
  validates :user_id, presence: true
  validates :category_id, presence: true

  belongs_to :analysis
  belongs_to :user
  belongs_to :category

  has_one_attached :cover_image
  has_one_attached :panel
end
