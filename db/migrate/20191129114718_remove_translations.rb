# frozen_string_literal: true

# The choice to do all this manually is due to the fact that the
# 'translate :name, :category' will be removed from the models in this same
# chunk of development, along with the globalize gem and all the globalize
# methods.
class RemoveTranslations < ActiveRecord::Migration[5.2]
  def up
    # copy from translation tables to table
    add_column :categories, :name,        :string, default: nil
    add_column :categories, :description, :text,   default: nil
    add_column :concepts,   :name,        :string, default: nil
    add_column :concepts,   :description, :text,   default: nil
    add_column :datasets,   :name,        :string, default: nil
    add_column :datasets,   :description, :text,   default: nil
    rename_column :data_elements, :description_en, :description
    remove_column :data_elements, :description_cy
    rename_column :data_table_rows, :description_en, :description
    remove_column :data_table_rows, :description_cy

    # copy translations from translation tables to table
    connection.execute <<-UPDATE_CATEGORIES
      UPDATE categories
      SET
        name = category_translations.name,
        description = category_translations.description
      FROM
        category_translations
        WHERE categories.id = category_translations.category_id
        AND category_translations.locale = 'en'
    UPDATE_CATEGORIES

    connection.execute <<-UPDATE_CONCEPTS
      UPDATE concepts
      SET
        name = concept_translations.name,
        description = concept_translations.description
      FROM
        concept_translations
        WHERE concepts.id = concept_translations.concept_id
        AND concept_translations.locale = 'en'
    UPDATE_CONCEPTS

    connection.execute <<-UPDATE_DATASETS
      UPDATE datasets
      SET
        name = dataset_translations.name,
        description = dataset_translations.description
      FROM
        dataset_translations
        WHERE datasets.id = dataset_translations.dataset_id
        AND dataset_translations.locale = 'en'
    UPDATE_DATASETS

    # 2020-01-28 moved here from the previous migration following the removal of
    # the Globalize gem
    Rails.configuration.datasets.each do |dataset|
      Dataset.skip_adaptations = true
      Dataset.find_or_create_by!(name: dataset['name'], tab_name: dataset['tab_name'],
                                 tab_type: dataset['type'], description: dataset['description'])
      Dataset.skip_adaptations = nil
    end

    # remove translation tables
    drop_table :category_translations
    drop_table :concept_translations
    drop_table :dataset_translations
  end

  def down
    # recreate translation tables
    create_table :category_translations do |t|
      t.belongs_to :category, type: :uuid, index: true
      t.string     :locale, null: false
      t.string     :name
      t.text       :description
      t.timestamps
    end

    create_table :concept_translations do |t|
      t.belongs_to :concept, type: :uuid, index: true
      t.string     :locale, null: false
      t.string     :name
      t.text       :description
      t.timestamps
    end

    create_table :dataset_translations do |t|
      t.belongs_to :dataset, type: :uuid, index: true
      t.string     :locale, null: false
      t.string     :name
      t.text       :description
      t.timestamps
    end

    # copy from table to translation tables
    connection.execute <<-UPDATE_CATEGORIES
      INSERT INTO category_translations (category_id, name, description, locale, created_at, updated_at)
      SELECT
        categories.id AS category_id,
        categories.name AS name,
        categories.description AS description,
        'en' AS locale,
        now() AS created_at,
        now() AS updated_at
      FROM categories
    UPDATE_CATEGORIES

    connection.execute <<-UPDATE_CONCEPTS
      INSERT INTO concept_translations (concept_id, name, description, locale, created_at, updated_at)
      SELECT
        concepts.id AS concept_id,
        concepts.name AS name,
        concepts.description AS description,
        'en' AS locale,
        now() AS created_at,
        now() AS updated_at
      FROM concepts
    UPDATE_CONCEPTS

    connection.execute <<-UPDATE_DATASETS
      INSERT INTO dataset_translations (dataset_id, name, description, locale, created_at, updated_at)
      SELECT
        datasets.id AS dataset_id,
        datasets.name,
        datasets.description,
        'en' AS locale,
        now() AS created_at,
        now() AS updated_at
      FROM datasets
    UPDATE_DATASETS

    # remove columns from original tables
    add_column    :data_table_rows, :description_cy, :text
    rename_column :data_table_rows, :description, :description_en
    add_column    :data_elements, :description_cy, :text
    rename_column :data_elements, :description, :description_en
    remove_column :datasets,   :description
    remove_column :datasets,   :name
    remove_column :concepts,   :description
    remove_column :concepts,   :name
    remove_column :categories, :description
    remove_column :categories, :name
  end
end
