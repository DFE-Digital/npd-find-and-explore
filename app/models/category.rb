class Category < ApplicationRecord
  translates :name
  translates :description

  has_ancestry
end
