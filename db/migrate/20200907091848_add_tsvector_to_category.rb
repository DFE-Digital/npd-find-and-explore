# frozen_string_literal: true

class AddTsvectorToCategory < ActiveRecord::Migration[5.2]
  def up
    add_column :categories, :tsvector_content_tsearch, :tsvector

    Category.rebuild_pg_search_documents
  end

  def down
    remove_column :categories, :tsvector_content_tsearch
  end
end
