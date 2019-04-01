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

  multisearchable against: %i[name description],
                  additional_attributes: ->(category) { { result_id: category.id, result_type: 'Category' } }

  def self.rebuild_pg_search_documents
    connection.execute <<-SQL
      INSERT INTO pg_search_documents (searchable_type, searchable_id, content, created_at, updated_at)
      SELECT 'Category' AS searchable_type,
      categories.id AS searchable_id,
      to_tsvector('english', string_agg(
       concat_ws(' ', category_translations.name, category_translations.description),
      ' ')) AS content,
      now() AS created_at,
      now() AS updated_at

      FROM categories
      LEFT OUTER JOIN category_translations
        ON categories.id = category_translations.category_id
      GROUP BY categories.id
    SQL
  end
end
