class Category < ApplicationRecord
  translates :name
  translates :description

  belongs_to :parent, class_name: "Category", foreign_key: :parent_id, optional: true, inverse_of: :categories
  has_many :categories, class_name: "Category", foreign_key: :parent_id, inverse_of: :parent

  # TODO: unit test
  scope :top_level, ->{ where(parent: nil) }
end
