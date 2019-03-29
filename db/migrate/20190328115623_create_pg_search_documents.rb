# frozen_string_literal: true

class CreatePgSearchDocuments < ActiveRecord::Migration[5.2]
  def self.up
    say_with_time('Creating table for pg_search multisearch') do
      create_table :pg_search_documents do |t|
        t.text :content
        t.belongs_to :searchable, type: :uuid, polymorphic: true, index: true
        t.belongs_to :result, type: :uuid, polymorphic: true, index: true
        t.timestamps null: false
      end
    end
    PgSearch::Multisearch.rebuild(Concept)
    PgSearch::Multisearch.rebuild(Category)
    PgSearch::Multisearch.rebuild(DataElement)
  end

  def self.down
    say_with_time('Dropping table for pg_search multisearch') do
      drop_table :pg_search_documents
    end
  end
end
