class Category < ApplicationRecord
  translates :name
  translates :description

  has_ancestry

  def my_parent
    parent
  end
end
