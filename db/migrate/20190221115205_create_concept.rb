# frozen_string_literal: true

# The Concept model, with translations using the Globalise gem
class CreateConcept < ActiveRecord::Migration[5.2]
  def change
    create_table :concepts, id: :uuid do |t|
      t.belongs_to :category, type: :uuid, index: true
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Concept.create_translation_table! name: :string, description: :text
      end

      dir.down do
        Concept.drop_translation_table!
      end
    end
  end
end
