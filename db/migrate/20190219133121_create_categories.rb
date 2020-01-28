# frozen_string_literal: true

# Add categories
class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories, id: :uuid do |t|
      t.timestamps
      t.references :parent, type: :uuid, index: true, foreign_key: { to_table: :categories }
    end

    create_table :category_translations do |t|
      t.references :category, null: false, index: false, type: :uuid
      t.string     :locale, null: false
      t.string     :name
      t.text       :description

      t.timestamps
    end

    add_index :category_translations, :category_id, name: :index_category_translations_on_category_id
    add_index :category_translations, :locale, name: :index_category_translations_on_locale
  end
end
