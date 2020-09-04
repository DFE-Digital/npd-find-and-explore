# frozen_string_literal: true

require 'active_support/concern'

module Indexing
  module DataElement
    extend ActiveSupport::Concern
    include PgSearch::Model

    included do
      multisearchable against: %i[name description]

      def create_or_update_pg_search_document
        conn = ActiveRecord::Base.connection

        if !pg_search_document
          conn.execute <<-SQL
            INSERT INTO pg_search_documents (searchable_type, searchable_id, content,
              searchable_name, searchable_category_id, searchable_year_from,
              searchable_year_to, searchable_tab_names, searchable_is_cla,
              searchable_created_at, searchable_updated_at, created_at, updated_at)
            SELECT
              'DataElement' AS searchable_type,
              #{conn.quote(id)} AS searchable_id,
              setweight(to_tsvector(#{conn.quote(npd_alias || '')}), 'A') ||
              setweight(to_tsvector(#{conn.quote([source_table_name, source_attribute_name].compact.join(' '))}), 'B') ||
              setweight(to_tsvector(#{conn.quote(description || '')}), 'C') ||
              setweight(to_tsvector(#{conn.quote(source_old_attribute_name || '')}), 'D')
              AS content,
              #{conn.quote(npd_alias)} AS searchable_name,
              #{conn.quote(concept&.category_id)} AS searchable_category_id,
              #{academic_year_collected_from || 'NULL'} AS searchable_year_from,
              #{academic_year_collected_to || 'NULL'} AS searchable_year_to,
              #{conn.quote("{#{datasets.map(&:tab_name).compact.join(', ')}}")} AS searchable_tab_names,
              #{conn.quote("{#{is_cla}}")} AS searchable_is_cla,
              #{conn.quote(created_at)} AS searchable_created_at,
              #{conn.quote(updated_at)} AS searchable_updated_at,
              now() AS created_at,
              now() AS updated_at
          SQL
        elsif should_update_pg_search_document?
          conn.execute <<-SQL
            UPDATE pg_search_documents
            SET
              content = setweight(to_tsvector(#{conn.quote(npd_alias || '')}), 'A') ||
                        setweight(to_tsvector(#{conn.quote([source_table_name, source_attribute_name].compact.join(' '))}), 'B') ||
                        setweight(to_tsvector(#{conn.quote(description || '')}), 'C') ||
                        setweight(to_tsvector(#{conn.quote(source_old_attribute_name || '')}), 'D'),
              searchable_name = #{conn.quote(npd_alias)},
              searchable_category_id = #{conn.quote(concept&.category_id)},
              searchable_year_from = #{academic_year_collected_from || 'NULL'},
              searchable_year_to = #{academic_year_collected_to || 'NULL'},
              searchable_tab_names = #{conn.quote("{#{datasets.map(&:tab_name).compact.join(', ')}}")},
              searchable_is_cla = #{conn.quote("{#{is_cla}}")},
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
          SELECT 'DataElement' AS searchable_type,
          data_elements.id AS searchable_id,
          setweight(to_tsvector(coalesce(data_elements.npd_alias, '')), 'A') ||
          setweight(to_tsvector(coalesce(concat_ws(' ', data_elements.source_table_name, data_elements.source_attribute_name), '')), 'B') ||
          setweight(to_tsvector(coalesce(data_elements.description, '')), 'C') ||
          setweight(to_tsvector(array_to_string(data_elements.source_old_attribute_name, ', ', '')), 'D')
          AS content,
          data_elements.npd_alias AS searchable_name,
          data_elements.concept_id AS searchable_category_id,
          coalesce(data_elements.academic_year_collected_from, date_part('year', current_timestamp)) AS searchable_year_from,
          coalesce(data_elements.academic_year_collected_to, date_part('year', current_timestamp)) AS searchable_year_to,
          array_agg(DISTINCT(datasets.tab_name)) AS searchable_tab_names,
          array_agg(data_elements.is_cla) AS searchable_is_cla,
          data_elements.created_at AS searchable_created_at,
          data_elements.updated_at AS searchable_updated_at,
          now() AS created_at,
          now() AS updated_at

          FROM data_elements
          LEFT OUTER JOIN concepts
            ON concepts.id = data_elements.concept_id
          LEFT OUTER JOIN data_elements_datasets
            ON data_elements.id = data_elements_datasets.data_element_id
          LEFT OUTER JOIN datasets
            ON data_elements_datasets.dataset_id = datasets.id
          GROUP BY data_elements.id
        SQL
      end
    end
  end
end
