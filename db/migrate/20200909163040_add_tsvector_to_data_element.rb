# frozen_string_literal: true

class AddTsvectorToDataElement < ActiveRecord::Migration[5.2]
  def up
    add_column :data_elements, :content_search, :text
    add_column :data_elements, :tsvector_content_tsearch, :tsvector
    add_column :data_elements, :searchable_tab_names, :string, array: true

    # Skip for conflict with later development
    # DataElement.rebuild_pg_search_documents
  end

  def down
    remove_column :data_elements, :content_search
    remove_column :data_elements, :tsvector_content_tsearch
    remove_column :data_elements, :searchable_tab_names
  end
end
