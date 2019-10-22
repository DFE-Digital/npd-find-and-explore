# frozen_string_literal: true

# A concept groups Data Elements that
# *mean the same thing*
#
# e.g. Free School Meals in Last 6 Years (concept) contains
#       - KS2Pupil.EVERFSM_6
#       - SchoolCensus.FSM6
class Concept < Versioned
  include PgSearch::Model

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
    no_concept = Concept.find_or_create_by(name: 'No Concept', category: no_category) do |concept|
      concept.description = 'This Concept is used to house data elements that are waiting to be categorised'
    end
    data_elements.each do |data_element|
      data_element.update(concept: no_concept)
    end
    reload
  end

  def create_or_update_pg_search_document
    conn = ActiveRecord::Base.connection
    data_elements_headers, data_elements_body, data_elements_years_from,
      data_elements_years_to, data_elements_tab_names, data_elements_is_cla = extract_complex_fields

    if !pg_search_document
      conn.execute <<-SQL
        INSERT INTO pg_search_documents (searchable_type, searchable_id, content,
          searchable_name, searchable_category_id, searchable_year_from,
          searchable_year_to, searchable_tab_names, searchable_is_cla,
          searchable_created_at, searchable_updated_at, created_at, updated_at)
        SELECT
          'Concept' AS searchable_type,
          #{conn.quote(id)} AS searchable_id,
          setweight(to_tsvector(#{conn.quote(name)}), 'A') ||
          setweight(to_tsvector(#{conn.quote(description)}), 'B') ||
          setweight(to_tsvector(#{conn.quote(data_elements_headers.join(' '))}), 'C') ||
          setweight(to_tsvector(#{conn.quote(data_elements_body.join(' '))}), 'D')
          AS content,
          #{conn.quote(name)} AS searchable_name,
          #{conn.quote(category_id)} AS searchable_category_id,
          #{data_elements_years_from.min || 'NULL'} AS searchable_year_from,
          #{data_elements_years_to.max || 'NULL'} AS searchable_year_to,
          #{data_elements_tab_names.present? ? "{#{data_elements_tab_names&.join(', ')}}" : 'NULL'} AS searchable_tab_names,
          #{data_elements_is_cla.present? ? "{#{data_elements_is_cla&.join(', ')}}" : 'NULL'} AS searchable_is_cla,
          #{conn.quote(created_at)} AS searchable_created_at,
          #{conn.quote(updated_at)} AS searchable_updated_at,
          now() AS created_at,
          now() AS updated_at
      SQL
    elsif should_update_pg_search_document?
      conn.execute <<-SQL
        UPDATE pg_search_documents
        SET
          content = setweight(to_tsvector(#{conn.quote(name)}), 'A') ||
                    setweight(to_tsvector(#{conn.quote(description)}), 'B') ||
                    setweight(to_tsvector(#{conn.quote(data_elements_headers.join(' '))}), 'C') ||
                    setweight(to_tsvector(#{conn.quote(data_elements_body.join(' '))}), 'D'),
          searchable_name = #{conn.quote(name)},
          searchable_category_id = #{conn.quote(category_id)},
          searchable_year_from = #{data_elements_years_from.min || 'NULL'},
          searchable_year_to = #{data_elements_years_to.max || 'NULL'},
          searchable_tab_names = #{data_elements_tab_names.present? ? "{#{data_elements_tab_names&.join(', ')}}" : 'NULL'},
          searchable_is_cla = #{data_elements_is_cla.present? ? "{#{data_elements_is_cla&.join(', ')}}" : 'NULL'},
          searchable_created_at = #{conn.quote(created_at)},
          searchable_updated_at = #{conn.quote(updated_at)},
          updated_at = NOW()
        WHERE searchable_type = 'Concept' AND searchable_id = #{conn.quote(id)}
      SQL
    end
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
        searchable_name, searchable_category_id, searchable_year_from,
        searchable_year_to, searchable_tab_names, searchable_is_cla,
        searchable_created_at, searchable_updated_at, created_at, updated_at)
      SELECT 'Concept' AS searchable_type,
      concepts.id AS searchable_id,
      setweight(to_tsvector(coalesce(string_agg(concept_translations.name, ' '), '')), 'A') ||
      setweight(to_tsvector(coalesce(string_agg(concept_translations.description, ' '), '')), 'B') ||
      setweight(to_tsvector(coalesce(string_agg(concat_ws(' ', data_elements.source_table_name, data_elements.source_attribute_name), ' '), '')), 'C') ||
      setweight(to_tsvector(coalesce(string_agg(concat_ws(' ', data_elements.description_en, data_elements.description_cy,
                                                          data_elements.npd_alias, data_elements.source_old_attribute_name,
                                                          data_elements.data_type), ' '), '')), 'D')
      AS content,
      MIN(concept_translations.name) AS searchable_name,
      category_id AS searchable_category_id,
      min(data_elements.academic_year_collected_from) AS searchable_year_from,
      max(data_elements.academic_year_collected_to) AS searchable_year_to,
      array_agg(DISTINCT(data_elements.tab_name)) AS searchable_tab_names,
      array_agg(DISTINCT(data_elements.is_cla)) AS searchable_is_cla,
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

  def extract_complex_fields
    data_elements_headers = []
    data_elements_body = []
    data_elements_years_from = []
    data_elements_years_to = []
    data_elements_tab_names = []
    data_elements_is_cla = []
    data_elements.each do |de|
      data_elements_headers.push([de.source_table_name, de.source_attribute_name].join(' '))
      data_elements_body.push([de.description_en, de.description_cy, de.npd_alias, de.source_old_attribute_name, de.data_type].join(' '))
      data_elements_years_from.push(de.academic_year_collected_from) if de.academic_year_collected_from.present?
      data_elements_years_to.push(de.academic_year_collected_to) if de.academic_year_collected_to.present?
      data_elements_tab_names.push(conn.quote(de.tab_name)) if de.tab_name.present?
      data_elements_is_cla.push(conn.quote(de.is_cla)) if de.is_cla.present?
    end
    [data_elements_headers, data_elements_body, data_elements_years_from.compact,
     data_elements_years_to.compact, data_elements_tab_names.compact&.flatten&.uniq,
     data_elements_is_cla.compact&.flatten&.uniq]
  end
end
