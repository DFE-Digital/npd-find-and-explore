# frozen_string_literal: true

# A concept groups Data Elements that
# *mean the same thing*
#
# e.g. Free School Meals in Last 6 Years (concept) contains
#       - KS2Pupil.EVERFSM_6
#       - SchoolCensus.FSM6
class Concept < ApplicationRecord
  include PgSearch

  belongs_to :category, inverse_of: :concepts
  has_many :data_elements, dependent: :nullify, inverse_of: :concept

  validates :name, uniqueness: { scope: :category }

  translates :name
  translates :description

  multisearchable against: %i[name description]

  def self.rebuild_pg_search_documents
    connection.execute <<-SQL
      INSERT INTO pg_search_documents (searchable_type, searchable_id, content,
        searchable_name, searchable_created_at, searchable_updated_at, created_at, updated_at)
      SELECT 'Concept' AS searchable_type,
      concepts.id AS searchable_id,
      to_tsvector('english', string_agg(
       concat_ws(' ', concept_translations.name, concept_translations.description,
         data_element_translations.description, data_elements.source_table_name,
         data_elements.source_attribute_name, data_elements.additional_attributes,
         array_to_string(data_elements.source_old_attribute_name, ' '),
         data_elements.academic_year_collected_from,
         data_elements.academic_year_collected_to,
         array_to_string(data_elements.collection_terms, ' '),
         data_elements.values),
      ' ')) AS content,
      MIN(concept_translations.name) AS searchable_name,
      MIN(concepts.created_at) AS searchable_created_at,
      MIN(concepts.updated_at) AS searchable_updated_at,
      now() AS created_at,
      now() AS updated_at

      FROM concepts
      LEFT OUTER JOIN concept_translations
        ON concepts.id = concept_translations.concept_id
      LEFT OUTER JOIN data_elements
        ON concepts.id = data_elements.concept_id
      LEFT OUTER JOIN data_element_translations
        ON data_elements.id = data_element_translations.data_element_id
      GROUP BY concepts.id
    SQL
  end
end
