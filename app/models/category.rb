# frozen_string_literal: true

# Categories are used to group related Concepts (and therefore Data Elements), for example:
#
#  Socio Economic Status (category)
#   |- IDACI (category)
#   |- Free School Meals (category)
#       |- Eligible for FSM in the past 6 years? (concept)
#
# A category contains one or more categories in a nested tree.
# A leaf-category (one without sub-categories) contains one or more
# concepts.
class Category < ApplicationRecord
  include PgSearch

  has_many :concepts, dependent: :destroy, inverse_of: :category

  validates :name, uniqueness: true

  translates :name
  translates :description

  has_ancestry

  multisearchable against: %i[name description]
end
