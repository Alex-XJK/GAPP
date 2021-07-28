class App < ApplicationRecord
  include Statuscheck

  validates :name, presence: { message: "App name must be given please." }
  validates :price, presence: { message: "Price not valid." }
  validates :description, presence: { message: "Description cannot be empty!" }
  validates :analysis_id, presence: { message: "Analysis method should not be nil..." }
  validates :user_id, presence: true
  validates :category_id, presence: true

  belongs_to :analysis
  belongs_to :user
  belongs_to :category

  has_one_attached :cover_image
  has_one_attached :panel
end
