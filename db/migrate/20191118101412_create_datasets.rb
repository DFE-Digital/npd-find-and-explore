# frozen_string_literal: true

class CreateDatasets < ActiveRecord::Migration[5.2]
  def up
    create_table :datasets, id: :uuid do |t|
      t.string :tab_name, null: false, unique: true
      t.string :tab_type, null: false

      t.timestamps
    end

    create_join_table :datasets, :data_elements, column_options: { type: :uuid } do |t|
      t.index :dataset_id
      t.index :data_element_id
      t.index %i[dataset_id data_element_id], unique: true
    end

    create_table :dataset_translations do |t|
      t.references :dataset, null: false, index: false, type: :uuid
      t.string     :locale, null: false
      t.string     :name
      t.text       :description

      t.timestamps
    end

    add_index :dataset_translations, :dataset_id, name: :index_dataset_translations_on_dataset_id
    add_index :dataset_translations, :locale, name: :index_dataset_translations_on_locale

    # 2020-01-28 Kept as historical documentation and moved to a later migration,
    # as removing the Globalize gem renders this inoperable at this point of the development
    # Rails.configuration.datasets.each do |dataset|
    #   Dataset.create!(name: dataset['name'], tab_name: dataset['tab_name'],
    #                   tab_type: dataset['type'], description: dataset['description'])
    # end

    remove_column :data_table_rows, :tab_name
    remove_column :data_elements, :tab_name
    remove_index :data_table_rows, %i[data_table_upload_id npd_alias]
    add_column :data_table_rows, :data_table_tab_id, :uuid
    add_index :data_table_rows, %i[data_table_tab_id npd_alias], unique: true
  end

  def down
    DataTable::Row.delete_all

    remove_index :data_table_rows, %i[data_table_tab_id npd_alias]
    remove_column :data_table_rows, :data_table_tab_id, :uuid
    add_index :data_table_rows, %i[data_table_upload_id npd_alias], unique: true
    add_column :data_elements, :tab_name, :string
    add_column :data_table_rows, :tab_name, :string

    drop_table :dataset_translations
    drop_join_table :datasets, :data_elements
    drop_table :datasets
  end
end
