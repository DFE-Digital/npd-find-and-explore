# frozen_string_literal: true

require 'active_support/concern'

module Indexing
  module Category
    extend ActiveSupport::Concern
    include PgSearch::Model

    included do
      multisearchable against: %i[name description]

      def create_or_update_pg_search_document
        conn = ActiveRecord::Base.connection
        if !pg_search_document
          conn.execute <<-SQL
            INSERT INTO pg_search_documents (searchable_type, searchable_id, content,
              searchable_name, searchable_created_at, searchable_updated_at, created_at, updated_at)
            SELECT 'Category' AS searchable_type,
            #{conn.quote(id)} AS searchable_id,
            setweight(to_tsvector(#{conn.quote(name || '')}), 'A') ||
              setweight(to_tsvector(#{conn.quote(description || '')}), 'B') AS content,
            #{conn.quote(name)} AS searchable_name,
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
                        setweight(to_tsvector(#{conn.quote(description || '')}), 'B'),
              searchable_name = #{conn.quote(name)},
              searchable_created_at = #{conn.quote(created_at)},
              searchable_updated_at = #{conn.quote(updated_at)},
              updated_at = NOW()
            WHERE searchable_type = 'Category' AND searchable_id = #{conn.quote(id)}
          SQL
        end
      end

      def self.rebuild_pg_search_documents
        connection.execute <<-SQL
          INSERT INTO pg_search_documents (searchable_type, searchable_id, content,
            searchable_name, searchable_created_at, searchable_updated_at, created_at, updated_at)
          SELECT 'Category' AS searchable_type,
          categories.id AS searchable_id,
          setweight(to_tsvector(coalesce(categories.name, '')), 'A') ||
          setweight(to_tsvector(coalesce(categories.description, '')), 'B')
          AS content,
          categories.name AS searchable_name,
          MIN(categories.created_at) AS searchable_created_at,
          MIN(categories.updated_at) AS searchable_updated_at,
          now() AS created_at,
          now() AS updated_at

          FROM categories
          GROUP BY categories.id
        SQL
      end
    end

  end
end
