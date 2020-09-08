# frozen_string_literal: true

require 'active_support/concern'

module Indexing
  module Category
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
        conn.execute <<-SQL
          UPDATE categories
          SET
            tsvector_content_tsearch = setweight(to_tsvector(#{conn.quote(name || '')}), 'A') ||
                                       setweight(to_tsvector(#{conn.quote(description || '')}), 'B'),
            updated_at = NOW()
          WHERE id = #{conn.quote(id)}
        SQL
      end

      def self.rebuild_pg_search_documents
        connection.execute <<-SQL
          UPDATE categories
          SET
            tsvector_content_tsearch = setweight(to_tsvector(coalesce(categories.name, '')), 'A') ||
                                       setweight(to_tsvector(coalesce(categories.description, '')), 'B'),
            updated_at = now()
        SQL
      end
    end
  end
end
