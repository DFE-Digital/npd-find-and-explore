# frozen_string_literal: true

# Add categories
class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories, id: :uuid do |t|
      t.timestamps
      t.references :parent, type: :uuid, index: true, foreign_key: { to_table: :categories }
    end

    reversible do |dir|
      dir.up do
        Category.create_translation_table! name: :string, description: :text
      end

      dir.down do
        Category.drop_translation_table!
      end
    end
  end
end
