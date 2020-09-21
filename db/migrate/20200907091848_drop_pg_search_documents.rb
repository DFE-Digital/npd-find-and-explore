# frozen_string_literal: true

class DropPgSearchDocuments < ActiveRecord::Migration[5.2]
  def up
    drop_table :pg_search_documents
  end

  def down
    create_table :pg_search_documents do |t|
      t.tsvector :content
      t.belongs_to :searchable, type: :uuid, polymorphic: true, index: true
      t.text :searchable_name
      t.datetime :searchable_created_at
      t.datetime :searchable_updated_at
      t.timestamps null: false
    end
    add_index(:pg_search_documents, :content, using: :gin)
  end
end
