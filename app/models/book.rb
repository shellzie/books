class Book < ActiveRecord::Base
  validates :title, presence: true
  validates :author, presence: true
  validates :publication_date, presence: true
  validates :isbn, presence: true
  # validates :image_path
  # validates :cover_type
  # validates :price
  # validates :rating
  # validates :num_reviews
  # validates :description
  # validates :age_range
  # validates :grade_level
  # validates :weight
  # validates :dimensions
  # validates :tags
  # validates :series
  # validates :num_pages
  # validates :publisher
end
