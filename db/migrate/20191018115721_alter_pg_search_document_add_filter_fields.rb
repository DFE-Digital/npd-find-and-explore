# frozen_string_literal: true

class AlterPgSearchDocumentAddFilterFields < ActiveRecord::Migration[5.2]
  def change
    add_column :pg_search_documents, :searchable_category_id, :string
    add_column :pg_search_documents, :searchable_year_from, :integer
    add_column :pg_search_documents, :searchable_year_to, :integer
    add_column :pg_search_documents, :searchable_tab_names, :string, array: true
    add_column :pg_search_documents, :searchable_is_cla, :boolean, array: true
  end
end
