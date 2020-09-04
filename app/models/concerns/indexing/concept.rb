# frozen_string_literal: true

require 'active_support/concern'

module Indexing
  module Concept
    extend ActiveSupport::Concern
    include PgSearch::Model

    included do
      multisearchable against: %i[name description]

      def create_or_update_pg_search_document
        conn = ActiveRecord::Base.connection
        data_elements_headers, data_elements_body, data_elements_years_from,
          data_elements_years_to, data_elements_tab_names, data_elements_is_cla = extract_complex_fields
        data_elements_processed_tabs = data_elements_tab_names.present? ? conn.quote("{#{data_elements_tab_names.join(', ')}}") : 'NULL'
        data_elements_processed_is_cla = data_elements_is_cla.present? ? conn.quote("{#{data_elements_is_cla.join(', ')}}") : 'NULL'

        if !pg_search_document
          conn.execute <<-SQL
            INSERT INTO pg_search_documents (searchable_type, searchable_id, content,
              searchable_name, searchable_category_id, searchable_year_from,
              searchable_year_to, searchable_tab_names, searchable_is_cla,
              searchable_created_at, searchable_updated_at, created_at, updated_at)
            SELECT
              'Concept' AS searchable_type,
              #{conn.quote(id)} AS searchable_id,
              setweight(to_tsvector(#{conn.quote(name || '')}), 'A') ||
              setweight(to_tsvector(#{conn.quote(description || '')}), 'B') ||
              setweight(to_tsvector(#{conn.quote(data_elements_headers.join(' '))}), 'C') ||
              setweight(to_tsvector(#{conn.quote(data_elements_body.join(' '))}), 'D')
              AS content,
              #{conn.quote(name)} AS searchable_name,
              #{conn.quote(category_id)} AS searchable_category_id,
              #{data_elements_years_from.min || 'NULL'} AS searchable_year_from,
              #{data_elements_years_to.max || 'NULL'} AS searchable_year_to,
              #{data_elements_processed_tabs} AS searchable_tab_names,
              #{data_elements_processed_is_cla} AS searchable_is_cla,
              #{conn.quote(created_at)} AS searchable_created_at,
              #{conn.quote(updated_at)} AS searchable_updated_at,
              now() AS created_at,
              now() AS updated_at
          SQL
        elsif should_update_pg_search_document?
          conn.execute <<-SQL
            UPDATE pg_search_documents
            SET
              content = setweight(to_tsvector(#{conn.quote(name || '')}), 'A') ||
                        setweight(to_tsvector(#{conn.quote(description || '')}), 'B') ||
                        setweight(to_tsvector(#{conn.quote(data_elements_headers.join(' '))}), 'C') ||
                        setweight(to_tsvector(#{conn.quote(data_elements_body.join(' '))}), 'D'),
              searchable_name = #{conn.quote(name)},
              searchable_category_id = #{conn.quote(category_id)},
              searchable_year_from = #{data_elements_years_from.min || 'NULL'},
              searchable_year_to = #{data_elements_years_to.max || 'NULL'},
              searchable_tab_names = #{data_elements_processed_tabs},
              searchable_is_cla = #{data_elements_processed_is_cla},
              searchable_created_at = #{conn.quote(created_at)},
              searchable_updated_at = #{conn.quote(updated_at)},
              updated_at = NOW()
            WHERE searchable_type = 'Concept' AND searchable_id = #{conn.quote(id)}
          SQL
        end
      end

      def self.rebuild_pg_search_documents
        connection.execute <<-SQL
          INSERT INTO pg_search_documents (searchable_type, searchable_id, content,
            searchable_name, searchable_category_id, searchable_year_from,
            searchable_year_to, searchable_tab_names, searchable_is_cla,
            searchable_created_at, searchable_updated_at, created_at, updated_at)
          SELECT 'Concept' AS searchable_type,
          concepts.id AS searchable_id,
          setweight(to_tsvector(coalesce(concepts.name, '')), 'A') ||
          setweight(to_tsvector(coalesce(concepts.description, '')), 'B') ||
          setweight(to_tsvector(coalesce(string_agg(concat_ws(' ', data_elements.source_table_name, data_elements.source_attribute_name), ' '), '')), 'C') ||
          setweight(to_tsvector(coalesce(string_agg(concat_ws(' ', data_elements.description, data_elements.npd_alias,
                                                              data_elements.source_old_attribute_name, data_elements.data_type), ' '), '')), 'D')
          AS content,
          concepts.name AS searchable_name,
          category_id AS searchable_category_id,
          min(coalesce(data_elements.academic_year_collected_from, date_part('year', current_timestamp))) AS searchable_year_from,
          max(coalesce(data_elements.academic_year_collected_to, date_part('year', current_timestamp))) AS searchable_year_to,
          array_agg(DISTINCT(datasets.tab_name)) AS searchable_tab_names,
          array_agg(DISTINCT(data_elements.is_cla)) AS searchable_is_cla,
          MIN(concepts.created_at) AS searchable_created_at,
          MIN(concepts.updated_at) AS searchable_updated_at,
          now() AS created_at,
          now() AS updated_at

          FROM concepts
          LEFT OUTER JOIN data_elements
            ON concepts.id = data_elements.concept_id
          LEFT OUTER JOIN data_elements_datasets
            ON data_elements.id = data_elements_datasets.data_element_id
          LEFT OUTER JOIN datasets
            ON data_elements_datasets.dataset_id = datasets.id
          GROUP BY concepts.id

        SQL
      end

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
