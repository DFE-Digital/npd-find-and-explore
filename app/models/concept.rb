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
  before_destroy :reassign_data_elements, prepend: true

  translates :name
  translates :description

  multisearchable against: %i[name description]

  def placeholder_description
    data_elements&.max { |a, b| (a&.description&.length || 0) <=> (b&.description&.length || 0) }&.description
  end

  def data_type
    types = data_elements&.collect(&:data_type)&.compact&.uniq
    return nil if types.empty?

    types.length == 1 ? types.first : 'Multiple'
  end

  def reassign_data_elements
    return true if data_elements.count.zero?
    raise(ActiveRecord::NotNullViolation, 'Cannot delete "No Concept" with data elements') if name == 'No Concept' && data_elements.count.positive?

    no_category = Category.find_or_create_by(name: 'No Category')
    no_concept = Concept.find_or_create_by(name: 'No Concept', category: no_category)
    data_elements.each do |data_element|
      data_element.update(concept: no_concept)
    end
    reload
  end

  def self.childless
    search = arel_table
             .project('concepts.id AS id, COUNT(data_elements) AS data_elements_count')
             .join(DataElement.arel_table, Arel::Nodes::OuterJoin).on('data_elements.concept_id = concepts.id')
             .group('concepts.id')

    where("concepts.id IN (SELECT id FROM (#{search.to_sql}) AS search WHERE search.data_elements_count = 0)")
  end

  def self.rebuild_pg_search_documents
    connection.execute <<-SQL
      INSERT INTO pg_search_documents (searchable_type, searchable_id, content,
        searchable_name, searchable_created_at, searchable_updated_at, created_at, updated_at)
      SELECT 'Concept' AS searchable_type,
      concepts.id AS searchable_id,
      setweight(to_tsvector(coalesce(string_agg(concept_translations.name, ' '), '')), 'A') ||
      setweight(to_tsvector(coalesce(string_agg(concept_translations.description, ' '), '')), 'B') ||
      setweight(to_tsvector(coalesce(string_agg(concat_ws(data_elements.source_table_name, data_elements.source_attribute_name), ' '), '')), 'C') ||
      setweight(to_tsvector(coalesce(string_agg(concat_ws(data_elements.description_en, data_elements.description_cy,
                                                          data_elements.npd_alias, data_elements.source_old_attribute_name,
                                                          data_elements.data_type), ' '), '')), 'D')
      AS content,
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
      GROUP BY concepts.id

    SQL
  end
end
