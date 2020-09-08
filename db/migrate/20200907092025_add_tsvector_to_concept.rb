# frozen_string_literal: true

class AddTsvectorToConcept < ActiveRecord::Migration[5.2]
  def up
    add_column :concepts, :tsvector_content_tsearch, :tsvector
    add_column :concepts, :searchable_year_from, :integer
    add_column :concepts, :searchable_year_to, :integer
    add_column :concepts, :searchable_tab_names, :string, array: true
    add_column :concepts, :searchable_is_cla, :boolean, array: true

    Concept.rebuild_pg_search_documents
  end

  def down
    remove_column :concepts, :tsvector_content_tsearch
    remove_column :concepts, :searchable_year_from
    remove_column :concepts, :searchable_year_to
    remove_column :concepts, :searchable_tab_names
    remove_column :concepts, :searchable_is_cla
  end
end
