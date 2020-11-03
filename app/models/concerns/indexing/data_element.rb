# frozen_string_literal: true

require 'active_support/concern'

module Indexing
  module DataElement
    extend ActiveSupport::Concern
    include PgSearch::Model

    included do
      mattr_accessor :skip_indexing
      before_save :update_pg_search_document, unless: :skip_indexing

      pg_search_scope :search,
                      against: %i[npd_alias source_table_name
                                  source_old_attribute_name description],
                      using: {
                        tsearch: {
                          dictionary: 'english',
                          tsvector_column: 'tsvector_content_tsearch',
                          prefix: true
                        },
                        dmetaphone: {
                          dictionary: 'english',
                          tsvector_column: 'dmetaphone_content_search',
                          prefix: true
                        }
                      }
      scope :exact, ->(search_terms) {
        search_words = search_terms.split(/\s+/)
        where(search_words.map { |word| "content_search LIKE #{connection.quote("%#{word}%")}" }.join(' AND '))
      }

      def update_pg_search_document
        conn = ActiveRecord::Base.connection

        conn.execute <<-SQL
          UPDATE data_elements
          SET
            content_search = #{conn.quote([npd_alias, source_table_name, source_attribute_name,
                                           description, source_old_attribute_name].flatten.compact.join(' '))},
            tsvector_content_tsearch = setweight(to_tsvector(#{conn.quote(npd_alias || '')}), 'A') ||
                                       setweight(to_tsvector(#{conn.quote([source_table_name, source_attribute_name].compact.join(' '))}), 'B') ||
                                       setweight(to_tsvector(#{conn.quote(description || '')}), 'C') ||
                                       setweight(to_tsvector(#{conn.quote(source_old_attribute_name.compact.join(' '))}), 'D'),
            dmetaphone_content_search = dmetaphone(#{conn.quote([npd_alias, source_table_name, source_attribute_name,
                                                                 description, source_old_attribute_name].flatten.compact.join(' '))}),
            searchable_tab_names = #{conn.quote("{#{datasets.map(&:tab_name).compact.join(', ')}}")},
            updated_at = now()
        SQL
      end

      def self.rebuild_pg_search_documents
        connection.execute <<-SQL
          UPDATE data_elements
          SET
            content_search = tsvector_query.content,
            tsvector_content_tsearch = tsvector_query.tsvector_content,
            dmetaphone_content_search = tsvector_query.dmetaphone_content,
            searchable_tab_names = tsvector_query.tab_names,
            updated_at = now()

          FROM (
            SELECT
              data_elements.id,
              concat_ws(' ', data_elements.npd_alias, data_elements.source_table_name,
                             data_elements.source_attribute_name, data_elements.description,
                             array_to_string(data_elements.source_old_attribute_name, ' ', ''))
                AS content,
              setweight(to_tsvector(coalesce(data_elements.npd_alias, '')), 'A') ||
                                       setweight(to_tsvector(coalesce(concat_ws(' ', data_elements.source_table_name, data_elements.source_attribute_name), '')), 'B') ||
                                       setweight(to_tsvector(coalesce(data_elements.description, '')), 'C') ||
                                       setweight(to_tsvector(array_to_string(data_elements.source_old_attribute_name, ' ', '')), 'D')
                AS tsvector_content,
              dmetaphone(concat_ws(' ', data_elements.npd_alias, data_elements.source_table_name,
                                        data_elements.source_attribute_name, data_elements.description,
                                        array_to_string(data_elements.source_old_attribute_name, ' ', '')))
                AS dmetaphone_content,
              array_agg(DISTINCT(datasets.tab_name)) AS tab_names

            FROM data_elements
            LEFT OUTER JOIN data_elements_datasets
              ON data_elements.id = data_elements_datasets.data_element_id
            LEFT OUTER JOIN datasets
              ON data_elements_datasets.dataset_id = datasets.id
            GROUP BY data_elements.id
          ) AS tsvector_query
          WHERE tsvector_query.id = data_elements.id
        SQL
      end
    end
  end
end
