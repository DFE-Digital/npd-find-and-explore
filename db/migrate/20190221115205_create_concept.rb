# frozen_string_literal: true

# The Concept model, with translations using the Globalise gem
class CreateConcept < ActiveRecord::Migration[5.2]
  def change
    create_table :concepts, id: :uuid do |t|
      t.belongs_to :category, type: :uuid, index: true
      t.timestamps
    end

    create_table :concept_translations do |t|
      t.references :concept, null: false, index: false, type: :uuid
      t.string     :locale, null: false
      t.string     :name
      t.text       :description

      t.timestamps
    end

    add_index :concept_translations, :concept_id, name: :index_concept_translations_on_concept_id
    add_index :concept_translations, :locale, name: :index_concept_translations_on_locale
  end
end
