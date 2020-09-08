# frozen_string_literal: true

require 'active_support/concern'

module Indexing
  module Concept
    extend ActiveSupport::Concern
    include PgSearch::Model

    included do
      mattr_accessor :skip_indexing
      before_save :update_pg_search_document, unless: :skip_indexing

      pg_search_scope :search,
                      against: %i[name description],
                      using: {
                        tsearch: {
                          dictionary: 'english',
                          tsvector_column: 'tsvector_content_tsearch',
                          prefix: true
                        }
                      }

      def update_pg_search_document
        conn = ActiveRecord::Base.connection
        data_elements_headers, data_elements_body, data_elements_years_from,
          data_elements_years_to, data_elements_tab_names, data_elements_is_cla = extract_complex_fields
        data_elements_processed_tabs = data_elements_tab_names.present? ? conn.quote("{#{data_elements_tab_names.join(', ')}}") : 'NULL'
        data_elements_processed_is_cla = data_elements_is_cla.present? ? conn.quote("{#{data_elements_is_cla.join(', ')}}") : 'NULL'

        conn.execute <<-SQL
          UPDATE concepts
          SET
            tsvector_content_tsearch = setweight(to_tsvector(#{conn.quote(name || '')}), 'A') ||
                                       setweight(to_tsvector(#{conn.quote(description || '')}), 'B') ||
                                       setweight(to_tsvector(#{conn.quote(data_elements_headers.join(' '))}), 'C') ||
                                       setweight(to_tsvector(#{conn.quote(data_elements_body.join(' '))}), 'D'),
            searchable_year_from = #{data_elements_years_from.min || 'NULL'},
            searchable_year_to = #{data_elements_years_to.max || 'NULL'},
            searchable_tab_names = #{data_elements_processed_tabs},
            searchable_is_cla = #{data_elements_processed_is_cla},
            updated_at = NOW()
          WHERE id = #{conn.quote(id)}
        SQL
      end

      def self.rebuild_pg_search_documents
        connection.execute <<-SQL
          UPDATE concepts

          SET
            tsvector_content_tsearch = tsvector_query.content,
            searchable_year_from = tsvector_query.year_from,
            searchable_year_to = tsvector_query.year_to,
            searchable_tab_names = tsvector_query.tab_names,
            searchable_is_cla = tsvector_query.is_cla,
            created_at = now(),
            updated_at = now()

          FROM (
            SELECT
              c.id,
              setweight(to_tsvector(coalesce(c.name, '')), 'A') ||
              setweight(to_tsvector(coalesce(c.description, '')), 'B') ||
              setweight(to_tsvector(coalesce(string_agg(concat_ws(' ', data_elements.source_table_name, data_elements.source_attribute_name), ' '), '')), 'C') ||
              setweight(to_tsvector(coalesce(string_agg(concat_ws(' ', data_elements.description, data_elements.npd_alias,
                                                                  data_elements.source_old_attribute_name, data_elements.data_type), ' '), '')), 'D')
                AS content,
              min(coalesce(data_elements.academic_year_collected_from, date_part('year', current_timestamp))) AS year_from,
              max(coalesce(data_elements.academic_year_collected_to, date_part('year', current_timestamp))) AS year_to,
              array_agg(DISTINCT(datasets.tab_name)) AS tab_names,
              array_agg(DISTINCT(data_elements.is_cla)) AS is_cla
            FROM
              concepts as c
              LEFT OUTER JOIN data_elements
                ON c.id = data_elements.concept_id
              LEFT OUTER JOIN data_elements_datasets
                ON data_elements.id = data_elements_datasets.data_element_id
              LEFT OUTER JOIN datasets
                ON data_elements_datasets.dataset_id = datasets.id

            GROUP BY c.id
          ) AS tsvector_query

          WHERE tsvector_query.id = concepts.id
        SQL
      end

    private

      def extract_complex_fields
        current_year = Time.now.year
        data_elements_headers = []
        data_elements_body = []
        data_elements_years_from = []
        data_elements_years_to = []
        data_elements_tab_names = []
        data_elements_is_cla = []
        data_elements.each do |de|
          data_elements_headers.push([de.source_table_name, de.source_attribute_name].join(' '))
          data_elements_body.push([de.description, de.npd_alias, de.source_old_attribute_name, de.data_type].join(' '))
          data_elements_years_from.push(de.academic_year_collected_from.present? ? de.academic_year_collected_from : current_year)
          data_elements_years_to.push(de.academic_year_collected_to.present? ? de.academic_year_collected_to : current_year)
          data_elements_tab_names.push(de.datasets.map(&:tab_name))
          data_elements_is_cla.push(de.is_cla) if de.is_cla.present?
        end
        [data_elements_headers, data_elements_body, data_elements_years_from.compact,
         data_elements_years_to.compact, data_elements_tab_names.compact&.flatten&.uniq,
         data_elements_is_cla.compact&.flatten&.uniq]
      end
    end
  end
end
